package com.example.cross_platform_vpn

import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.os.Build
import android.util.Log
import io.nekohasekai.libbox.InterfaceUpdateListener
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.net.NetworkInterface

object DefaultNetworkMonitor {

    private const val TAG = "DefaultNetworkMonitor"

    var defaultNetwork: Network? = null
    private var listener: InterfaceUpdateListener? = null
    private var connectivityManager: ConnectivityManager? = null

    // Callback to pre-cache interfaces before updating sing-box
    var onInterfaceCacheRequest: ((Network?) -> Unit)? = null

    suspend fun start(cm: ConnectivityManager) {
        Log.d(TAG, "🔍 Starting DefaultNetworkMonitor")
        connectivityManager = cm

        // Set CM for DefaultNetworkListener
        DefaultNetworkListener.setConnectivityManager(cm)

        // Register with the actor - it will handle all network changes
        DefaultNetworkListener.start(this) { network ->
            defaultNetwork = network
            checkDefaultInterfaceUpdate(network)
        }

        // Get initial network
        defaultNetwork = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            cm.activeNetwork
        } else {
            DefaultNetworkListener.get()
        }

        Log.d(TAG, "✅ Initial network: $defaultNetwork")
    }

    suspend fun stop() {
        Log.d(TAG, "🔍 Stopping DefaultNetworkMonitor")
        DefaultNetworkListener.stop(this)
        connectivityManager = null
        listener = null
        defaultNetwork = null
        onInterfaceCacheRequest = null
    }

    fun setListener(newListener: InterfaceUpdateListener?) {
        Log.d(TAG, "🔍 setListener called: ${newListener != null}")
        listener = newListener

        // Trigger initial update
        if (newListener != null) {
            checkDefaultInterfaceUpdate(defaultNetwork)
        }
    }

    private fun checkDefaultInterfaceUpdate(newNetwork: Network?) {
        val listener = listener ?: return
        val cm = connectivityManager ?: return

        if (newNetwork != null) {
            val linkProperties = cm.getLinkProperties(newNetwork)
            val interfaceName = linkProperties?.interfaceName

            if (interfaceName == null) {
                Log.w(TAG, "⚠️ No interface name for network")
                return
            }

            // CRITICAL: Skip VPN interfaces - don't send any updates
            if (interfaceName.startsWith("tun") || interfaceName.startsWith("ppp")) {
                Log.d(TAG, "⏭️ Skipping VPN interface: $interfaceName")
                return
            }

            // Try to get interface index with retries
            var interfaceIndex = -1
            for (attempt in 0 until 10) {
                try {
                    interfaceIndex = NetworkInterface.getByName(interfaceName)?.index ?: -1
                    if (interfaceIndex != -1) break
                } catch (e: Exception) {
                    if (attempt < 9) {
                        Thread.sleep(100)
                    }
                }
            }

            val networkCapabilities = cm.getNetworkCapabilities(newNetwork)
            val isExpensive = networkCapabilities?.let {
                !it.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_METERED)
            } ?: false

            val isConstrained = networkCapabilities?.let {
                !it.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_RESTRICTED)
            } ?: false

            Log.d(TAG, "✅ Preparing to update interface: name=$interfaceName, index=$interfaceIndex")

            // CRITICAL FIX: Pre-cache the interfaces BEFORE notifying sing-box
            // This ensures getInterfaces() will return cached data and won't cause stack overflow
            GlobalScope.launch(Dispatchers.IO) {
                try {
                    // Step 1: Request the service to build and cache interfaces
                    Log.d(TAG, "📦 Requesting interface cache build...")
                    onInterfaceCacheRequest?.invoke(newNetwork)

                    // Step 2: Small delay to ensure cache is built
                    Thread.sleep(100)

                    // Step 3: Now safely notify sing-box
                    Log.d(TAG, "📡 Notifying sing-box: $interfaceName (index=$interfaceIndex)")
                    listener.updateDefaultInterface(interfaceName, interfaceIndex, isExpensive, isConstrained)
                    Log.d(TAG, "✅ Interface update completed")
                } catch (e: Exception) {
                    Log.e(TAG, "❌ Failed to update interface", e)
                }
            }
        } else {
            Log.d(TAG, "⚠️ No default network")
        }
    }
}
