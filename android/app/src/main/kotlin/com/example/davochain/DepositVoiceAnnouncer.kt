package com.example.davochain

import android.app.NotificationManager
import android.content.Context
import android.media.AudioAttributes
import android.media.AudioManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

/** Isolated from verification voice guidance; never accepts private text. */
class DepositVoiceAnnouncer(private val context: Context) {
    private val main = Handler(Looper.getMainLooper())
    private var engine: TextToSpeech? = null
    private var ready = false
    private var epoch = 0
    private data class Request(val result: MethodChannel.Result, val fallback: Any, val speech: Boolean, val action: (TextToSpeech) -> Any)
    private val pending = mutableListOf<Request>()
    private val attributes = AudioAttributes.Builder()
        .setUsage(AudioAttributes.USAGE_NOTIFICATION)
        .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH).build()

    private fun soundAllowed(): Boolean = try {
        val audio = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val notifications = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channel = if (Build.VERSION.SDK_INT >= 26) notifications.getNotificationChannel("davo_transactions_v1") else null
        audio.mode == AudioManager.MODE_NORMAL &&
            audio.ringerMode == AudioManager.RINGER_MODE_NORMAL &&
            audio.getStreamVolume(AudioManager.STREAM_NOTIFICATION) > 0 &&
            notifications.areNotificationsEnabled() &&
            notifications.currentInterruptionFilter == NotificationManager.INTERRUPTION_FILTER_ALL &&
            (Build.VERSION.SDK_INT < 26 || (channel != null && channel.importance != NotificationManager.IMPORTANCE_NONE && channel.sound != null))
    } catch (_: Exception) { false }

    fun voices(result: MethodChannel.Result) = withEngine(result, emptyList<Any>()) { speech ->
        val counts = mutableMapOf<String, Int>()
        speech.voices.orEmpty().filter { it.locale.language == "en" && !it.features.orEmpty().contains(TextToSpeech.Engine.KEY_FEATURE_NOT_INSTALLED) }
            .sortedWith(compareBy({ it.locale.toLanguageTag() }, { it.isNetworkConnectionRequired }, { it.name }))
            .map { voice ->
                val locale = voice.locale.getDisplayName(Locale.ENGLISH)
                val index = (counts[locale] ?: 0) + 1
                counts[locale] = index
                mapOf("id" to voice.name, "label" to "$locale - Voice $index", "locale" to voice.locale.toLanguageTag(), "offline" to !voice.isNetworkConnectionRequired)
            }
    }

    fun speak(result: MethodChannel.Result, voiceId: String? = null, style: String? = null) {
        if (!soundAllowed()) { result.success(false); return }
        withEngine(result, false, true) { speech ->
            // Reset the base voice every time; a removed voice falls back to English.
            speech.setLanguage(Locale.ENGLISH)
            val voice = speech.voices.orEmpty().firstOrNull { it.name == voiceId && it.locale.language == "en" && !it.features.orEmpty().contains(TextToSpeech.Engine.KEY_FEATURE_NOT_INSTALLED) }
            if (voice != null) speech.setVoice(voice)
            speech.setPitch(when (style) { "deep" -> 0.78f; "warm" -> 0.92f; "bright" -> 1.25f; else -> 1.0f })
            speech.setSpeechRate(if (style == "warm") 0.88f else 0.96f)
            soundAllowed() && speech.speak("Payment received in Davochain", TextToSpeech.QUEUE_FLUSH, null, "deposit-$epoch") == TextToSpeech.SUCCESS
        }
    }

    private fun withEngine(result: MethodChannel.Result, fallback: Any, speechRequest: Boolean = false, action: (TextToSpeech) -> Any) {
        if (ready && engine != null) {
            try { result.success(action(engine!!)) } catch (_: Exception) { result.success(fallback) }
            return
        }
        pending.add(Request(result, fallback, speechRequest, action))
        if (engine != null) return
        val requestEpoch = epoch
        try {
            engine = TextToSpeech(context) { status -> main.post {
                if (requestEpoch != epoch) return@post
                val speech = engine
                ready = status == TextToSpeech.SUCCESS && speech != null && speech.setLanguage(Locale.ENGLISH) >= 0
                if (ready) {
                    speech?.setAudioAttributes(attributes)
                    speech?.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
                        override fun onStart(id: String?) { android.util.Log.i("DavoDepositVoice", "Deposit voice started") }
                        override fun onDone(id: String?) { android.util.Log.i("DavoDepositVoice", "Deposit voice completed") }
                        @Deprecated("Legacy callback") override fun onError(id: String?) { android.util.Log.i("DavoDepositVoice", "Deposit voice unavailable") }
                    })
                }
                val requests = pending.toList()
                pending.clear()
                requests.forEach { request ->
                    try { request.result.success(if (ready && speech != null) request.action(speech) else request.fallback) }
                    catch (_: Exception) { request.result.success(request.fallback) }
                }
                if (!ready) { engine?.shutdown(); engine = null }
            } }
            main.postDelayed({ if (requestEpoch == epoch && !ready) stop() }, 8000)
        } catch (_: Exception) { stop() }
    }

    fun cancelSpeech() {
        val requests = pending.filter { it.speech }
        pending.removeAll(requests.toSet())
        requests.forEach { it.result.success(false) }
        engine?.stop()
    }

    fun stop() {
        epoch++
        pending.forEach { it.result.success(it.fallback) }
        pending.clear()
        engine?.stop()
        if (!ready) { engine?.shutdown(); engine = null }
    }

    fun close() {
        stop()
        engine?.shutdown()
        engine = null
        ready = false
    }
}
