# Deposit voice alert

User-approved design, 16 October 2026. This is an optional, account-scoped setting in Notification Settings. It starts off, including when upgrading older settings. A separate Test voice action previews the same phrase without creating a deposit, changing money or adding an inbox entry.

The only phrase is **Payment received in Davochain**. Native speech never accepts an amount, account identifier, name or caller-provided text. Only a newly posted, completed deposit notification qualifies. Pending/failed deposits, withdrawals, security events, marketing, suppressed notifications, historical entries and duplicate receipt updates do not speak.

The existing delivery ledger is checkpointed as posted before speech is requested, so speech is at most once and never replayed after a restart. Speech is best effort and asynchronous: a slow or unavailable engine cannot block later notifications, affect a balance, or downgrade the posted event. Turning it off, leaving the account or destroying the activity stops pending speech.

Android uses a dedicated text-to-speech instance, independent of face-verification guidance. It uses notification audio attributes and checks normal ringer mode, nonzero notification volume, Do Not Disturb, transaction channel sound/importance, notification permission and audio mode before playback. It never changes phone volume, DND or sound settings. Initial speech setup has an eight-second deadline and reports failure if no usable English voice is available. No microphone or recording permission is requested.

Current coverage is the app's accepted local-event/notification path. Actual provider deposit callbacks and terminated-app/background push execution require the later backend adapter; this feature does not invent incoming transfers.

References: [Android TextToSpeech](https://developer.android.com/reference/android/speech/tts/TextToSpeech), [AudioManager](https://developer.android.com/reference/android/media/AudioManager), [NotificationManager](https://developer.android.com/reference/android/app/NotificationManager).

Verification: 55 focused tests passed, then the full regression passed 759 tests with 17 optional captures skipped. This includes default-off/roundtrip, completed-only, post-before-speech, duplicate/restart suppression, denied/failed posts, disabling during an await, account-switch cancellation, a stalled speech engine not blocking later notifications, fixed no-argument preview calls and settings at 200 percent text. Independent review found a replaced-initialization-request timeout edge case and unprefixed test fixtures; both were corrected. The stalled-speech and account-switch regressions were observed failing before their fixes.

Final static analysis passed. Build56 (0.19.1+56) compiled successfully and was installed over the existing app on Android API34 without clearing data. Test voice requested playback and Android logged `DavoDepositVoice: Deposit voice completed` at 16:41:34 UTC+1. APK SHA256: `876A523BDEBA7AEBB681770DD7719228D92394792661D2F21BC1622F9E8DEBD6`. Runtime quiet-mode checks are implemented; an attempted empirical DND check was inconclusive because the shared emulator changed screens, and DND was restored. Physical-device silent/DND checks remain part of device acceptance.
