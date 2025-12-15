package com.example.screentime

import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.screentime/usage_monitor"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getInstalledApps") {
                val apps = getInstalledApps()
                result.success(apps)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getInstalledApps(): List<Map<String, String>> {
        val appsList = mutableListOf<Map<String, String>>()
        val packageManager = context.packageManager
        
        // Get all installed packages
        val packages = packageManager.getInstalledPackages(PackageManager.GET_META_DATA)

        for (packageInfo in packages) {
            // Safely access applicationInfo using ?
            val appInfo = packageInfo.applicationInfo
            
            // Explicit null check
            if (appInfo != null) {
                // Use safe call ?. just in case, though it should be non-null here
                val label = appInfo.loadLabel(packageManager)
                val appName = label?.toString() ?: "Unknown App"
                val packageName = packageInfo.packageName
                
                // Ensure package name is not null (though unlikely)
                if (packageName != null && packageManager.getLaunchIntentForPackage(packageName) != null) {
                    val appMap = mapOf(
                        "appName" to appName,
                        "packageName" to packageName
                    )
                    appsList.add(appMap)
                }
            }
        }
        return appsList
    }
}