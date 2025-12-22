package com.example.screentime

import android.content.Intent
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
        
        // Create an intent that targets the "Main" action for "Launcher" apps
        // This effectively asks Android: "Give me everything in the App Drawer"
        val intent = Intent(Intent.ACTION_MAIN, null)
        intent.addCategory(Intent.CATEGORY_LAUNCHER)

        // Query for all activities that match this intent
        val apps = packageManager.queryIntentActivities(intent, 0)

        for (resolveInfo in apps) {
            val activityInfo = resolveInfo.activityInfo
            
            // Get the app name and package name
            val appName = resolveInfo.loadLabel(packageManager).toString()
            val packageName = activityInfo.packageName

            // Avoid duplicates (sometimes an app has multiple launcher icons)
            val alreadyExists = appsList.any { it["packageName"] == packageName }
            
            if (!alreadyExists) {
                val appMap = mapOf(
                    "appName" to appName,
                    "packageName" to packageName
                )
                appsList.add(appMap)
            }
        }
        
        // Optional: Sort alphabetically for a nicer initial list
        appsList.sortBy { it["appName"] }
        
        return appsList
    }
}