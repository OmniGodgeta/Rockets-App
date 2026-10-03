package com.example.rockets

import android.content.Intent
import android.view.View
import android.view.ViewGroup
import android.webkit.WebView
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Opens another installed app by package name ("open in the ISS Live
        // Now app", "open Stellarium"). Each package must also be listed in
        // the manifest's <queries>, or Android 11+ hides it from us.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "rockets/external_apps")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "launch" -> {
                        val packages = call.argument<List<String>>("packages") ?: emptyList()
                        for (pkg in packages) {
                            val intent: Intent? = packageManager.getLaunchIntentForPackage(pkg)
                            if (intent != null) {
                                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                startActivity(intent)
                                result.success(pkg)
                                return@setMethodCallHandler
                            }
                        }
                        result.success(null)
                    }
                    // Chromium only sends device-orientation events to a
                    // focused page, and a WebView doesn't get focus until it's
                    // touched; the star map's auto tracking needs it at once.
                    "focusWebViews" -> {
                        window.decorView.post {
                            focusWebViews(window.decorView)
                            result.success(null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun focusWebViews(view: View) {
        if (view is WebView) {
            view.isFocusable = true
            view.isFocusableInTouchMode = true
            view.requestFocus()
            return
        }
        if (view is ViewGroup) {
            for (i in 0 until view.childCount) focusWebViews(view.getChildAt(i))
        }
    }
}
