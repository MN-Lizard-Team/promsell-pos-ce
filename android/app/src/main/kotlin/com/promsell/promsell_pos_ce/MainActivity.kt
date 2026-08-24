package com.promsell.promsell_pos_ce

import android.os.StatFs
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "promsell/secure_screen",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "setSecure" -> {
                    val enable = call.argument<Boolean>("enable") ?: true
                    runOnUiThread {
                        if (enable) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        }
                    }
                    result.success(null)
                }
                "getFreeDiskSpace" -> {
                    val path = call.argument<String>("path")
                    if (path == null) {
                        result.error("INVALID_ARGUMENT", "Missing 'path' argument", null)
                    } else {
                        try {
                            val availableBytes = StatFs(path).availableBytes
                            result.success(availableBytes)
                        } catch (e: Exception) {
                            // Invalid path or unavailable volume — report unknown.
                            result.success(-1L)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
