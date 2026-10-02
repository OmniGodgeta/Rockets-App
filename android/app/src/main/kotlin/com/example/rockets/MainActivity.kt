package com.example.rockets

import android.content.Intent
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
                    else -> result.notImplemented()
                }
            }
    }
}
