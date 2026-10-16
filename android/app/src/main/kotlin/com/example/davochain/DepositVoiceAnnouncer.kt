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
    private var pending: MethodChannel.Result? = null
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

    fun speak(result: MethodChannel.Result) {
        if (!soundAllowed()) { result.success(false); return }
        if (ready) { result.success(play()); return }
        pending?.success(false)
        pending = result
        if (engine != null) return
        val requestEpoch = epoch
        try {
            engine = TextToSpeech(context) { status -> main.post {
                if (requestEpoch != epoch) return@post
                val speech = engine
                ready = status == TextToSpeech.SUCCESS && speech != null && speech.setLanguage(Locale.ENGLISH) >= 0
                if (ready) {
                    speech?.setAudioAttributes(attributes)
                    speech?.setSpeechRate(0.96f)
                    speech?.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
                        override fun onStart(id: String?) { android.util.Log.i("DavoDepositVoice", "Deposit voice started") }
                        override fun onDone(id: String?) { android.util.Log.i("DavoDepositVoice", "Deposit voice completed") }
                        @Deprecated("Legacy callback") override fun onError(id: String?) { android.util.Log.i("DavoDepositVoice", "Deposit voice unavailable") }
                    })
                }
                val response = pending
                pending = null
                response?.success(if (ready) play() else false)
                if (!ready) { engine?.shutdown(); engine = null }
            } }
            main.postDelayed({
                if (requestEpoch == epoch && !ready && pending != null) {
                    stop()
                }
            }, 8000)
        } catch (_: Exception) { stop() }
    }

    private fun play(): Boolean = try {
        soundAllowed() && engine?.speak("Payment received in Davochain", TextToSpeech.QUEUE_FLUSH, null, "deposit-$epoch") == TextToSpeech.SUCCESS
    } catch (_: Exception) { false }

    fun stop() {
        epoch++
        pending?.success(false)
        pending = null
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
