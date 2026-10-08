package com.example.davochain

import android.os.Build
import android.os.Bundle
import android.app.Activity
import android.content.ClipData
import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Environment
import android.provider.MediaStore
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    private val receiptWorker = Executors.newSingleThreadExecutor()
    private var pendingSave: PendingReceiptSave? = null
    private data class PendingReceiptSave(val file: File, val result: MethodChannel.Result)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "davochain/receipt_export")
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "shareTarget", "download" -> {
                            val file = validatedReceipt(call.argument<String>("path"))
                            val mime = call.argument<String>("mimeType") ?: ""
                            if (mime != "image/png" && mime != "application/pdf") {
                                throw IllegalArgumentException("Unsupported receipt format")
                            }
                            if ((mime == "image/png" && file.extension != "png") ||
                                (mime == "application/pdf" && file.extension != "pdf")) {
                                throw IllegalArgumentException("Receipt format mismatch")
                            }
                            if (call.method == "shareTarget") {
                                val target = call.argument<String>("package") ?: ""
                                if (target != "com.twitter.android" && target != "org.telegram.messenger") {
                                    throw IllegalArgumentException("Unsupported sharing target")
                                }
                                shareReceipt(file, mime, target, call.argument<String>("title"), result)
                            } else {
                                downloadReceipt(file, mime, result)
                            }
                        }
                        else -> result.notImplemented()
                    }
                } catch (error: Exception) {
                    result.error("receipt_error", error.message ?: "Receipt action unavailable", null)
                }
            }
    }

    private fun validatedReceipt(path: String?): File {
        require(!path.isNullOrEmpty()) { "Receipt path missing" }
        val file = File(path).canonicalFile
        val root = File(cacheDir, "receipts").canonicalFile
        require(file.parentFile == root && file.isFile && file.length() > 8) {
            "Receipt file unavailable"
        }
        // Reject mislabeled or empty exports before sharing or saving them.
        val header = ByteArray(8)
        file.inputStream().use { require(it.read(header) == 8) }
        val png = header.contentEquals(byteArrayOf(0x89.toByte(), 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a))
        val pdf = String(header.copyOfRange(0, 5), Charsets.US_ASCII) == "%PDF-"
        require((file.extension == "png" && png) || (file.extension == "pdf" && pdf)) {
            "Invalid receipt bytes"
        }
        return file
    }

    private fun shareReceipt(file: File, mime: String, target: String,
        title: String?, result: MethodChannel.Result) {
        val uri = FileProvider.getUriForFile(this, "$packageName.receipt_files", file)
        val intent = Intent(Intent.ACTION_SEND).apply {
            type = mime
            setPackage(target)
            putExtra(Intent.EXTRA_STREAM, uri)
            putExtra(Intent.EXTRA_SUBJECT, title)
            clipData = ClipData.newUri(contentResolver, file.name, uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        if (intent.resolveActivity(packageManager) == null) {
            result.success(false)
            return
        }
        try {
            startActivity(intent)
            result.success(true)
        } catch (_: android.content.ActivityNotFoundException) {
            result.success(false)
        }
    }

    private fun downloadReceipt(file: File, mime: String, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            receiptWorker.execute {
                var uri: Uri? = null
                try {
                    val values = ContentValues().apply {
                        put(MediaStore.Downloads.DISPLAY_NAME, file.name)
                        put(MediaStore.Downloads.MIME_TYPE, mime)
                        put(MediaStore.Downloads.RELATIVE_PATH, "${Environment.DIRECTORY_DOWNLOADS}/Davochain")
                        put(MediaStore.Downloads.IS_PENDING, 1)
                    }
                    uri = contentResolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                        ?: throw IllegalStateException("Downloads unavailable")
                    copyReceipt(file, uri!!)
                    val published = contentResolver.update(uri!!,
                        ContentValues().apply { put(MediaStore.Downloads.IS_PENDING, 0) }, null, null)
                    check(published > 0) { "Could not finish saving the receipt" }
                    runOnUiThread { result.success("Downloads/Davochain") }
                } catch (error: Exception) {
                    uri?.let { contentResolver.delete(it, null, null) }
                    runOnUiThread { result.error("download_failed", error.message, null) }
                }
            }
        } else {
            check(pendingSave == null) { "A save dialog is already open" }
            pendingSave = PendingReceiptSave(file, result)
            try {
                startActivityForResult(Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = mime
                    putExtra(Intent.EXTRA_TITLE, file.name)
                }, 4107)
            } catch (error: Exception) {
                pendingSave = null
                throw error
            }
        }
    }

    private fun copyReceipt(file: File, uri: Uri) {
        val output = contentResolver.openOutputStream(uri, "w")
            ?: throw IllegalStateException("Could not open the selected location")
        output.use { stream ->
            file.inputStream().use { input ->
                val count = input.copyTo(stream)
                check(count == file.length()) { "Incomplete receipt download" }
            }
            stream.flush()
        }
    }

    @Deprecated("Uses the Android document picker callback")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != 4107) return
        val save = pendingSave ?: return
        pendingSave = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            save.result.success(null)
            return
        }
        receiptWorker.execute {
            try {
                copyReceipt(save.file, uri)
                runOnUiThread { save.result.success("selected location") }
            } catch (error: Exception) {
                runOnUiThread { save.result.error("download_failed", error.message, null) }
            }
        }
    }

    override fun onDestroy() {
        pendingSave?.result?.error("download_cancelled", "Save dialog closed", null)
        pendingSave = null
        receiptWorker.shutdown()
        super.onDestroy()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            splashScreen.setOnExitAnimationListener { splash ->
                splash.animate().alpha(0f).setDuration(120L)
                    .withEndAction { splash.remove() }.start()
            }
        }
    }
}
