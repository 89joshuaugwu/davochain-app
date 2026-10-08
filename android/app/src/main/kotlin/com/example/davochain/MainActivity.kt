package com.example.davochain

import android.os.Build
import android.os.Bundle

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
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
