package com.example.cross_platform_vpn

import android.app.Activity
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.vulcain.vpn/control"
    private val VPN_REQUEST_CODE = 1001
    private val TAG = "MainActivity"

    private var pendingResult: MethodChannel.Result? = null

    // ❌ DELETE THIS ENTIRE onCreate METHOD - it's now in VpnApplication
    // override fun onCreate(savedInstanceState: Bundle?) {
    //     super.onCreate(savedInstanceState)
    //     Seq.setContext(applicationContext)
    //     Log.d(TAG, "Gomobile initialized")
    // }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            Log.d(TAG, "Method call: ${call.method}")

            when (call.method) {
                "startVpn" -> {
                    if (pendingResult != null) {
                        result.error(
                            "VPN_BUSY",
                            "VPN permission request already in progress",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    pendingResult = result
                    val intent = VpnService.prepare(this)

                    if (intent != null) {
                        Log.d(TAG, "Requesting VPN permission")
                        startActivityForResult(intent, VPN_REQUEST_CODE)
                    } else {
                        Log.d(TAG, "VPN permission already granted")
                        pendingResult?.let { r ->
                            startVpnInternal(r)
                            pendingResult = null
                        }
                    }
                }

                "stopVpn" -> {
                    stopVpnInternal(result)
                }

                "getStatus" -> {
                    result.success(MyVpnService.isRunning)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun startVpnInternal(result: MethodChannel.Result) {
        try {
            val intent = Intent(this, MyVpnService::class.java)
            Log.d(TAG, "Starting VPN service")

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }

            result.success(true)

        } catch (e: Exception) {
            Log.e(TAG, "Failed to start VPN", e)
            result.error(
                "VPN_START_ERROR",
                e.message ?: "Unknown error",
                null
            )
        }
    }

    private fun stopVpnInternal(result: MethodChannel.Result) {
        try {
            Log.d(TAG, "Stopping VPN service")
            val intent = Intent(this, MyVpnService::class.java).apply {
                action = "STOP_VPN"
            }
            startService(intent)
            result.success(true)

        } catch (e: Exception) {
            Log.e(TAG, "Failed to stop VPN", e)
            result.error(
                "VPN_STOP_ERROR",
                e.message ?: "Unknown error",
                null
            )
        }
    }

    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?
    ) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == VPN_REQUEST_CODE) {
            pendingResult?.let { result ->
                pendingResult = null

                if (resultCode == Activity.RESULT_OK) {
                    Log.d(TAG, "VPN permission granted")
                    startVpnInternal(result)
                } else {
                    Log.w(TAG, "VPN permission denied")
                    result.error(
                        "VPN_PERMISSION_DENIED",
                        "User denied VPN permission",
                        null
                    )
                }
            }
        }
    }
}
