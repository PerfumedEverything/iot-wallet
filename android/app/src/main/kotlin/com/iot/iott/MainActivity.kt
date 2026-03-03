package com.iot.iott

import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.iot.iott/background"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "moveToBackground" -> {
                    Log.d("MainActivity", "🏠 moveToBackground from Flutter")
                    moveAppToHome()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        Log.d("MainActivity", "✅ MethodChannel initialized")
    }

    private fun moveAppToHome() {
        val intent = Intent(Intent.ACTION_MAIN)
        intent.addCategory(Intent.CATEGORY_HOME)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(intent)
    }
}
