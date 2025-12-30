package com.example.screentime

import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import android.util.Log

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

    private fun getInstalledApps(): List<Map<String, Any?>> {
        val appsList = mutableListOf<Map<String, Any?>>()
        val packageManager = context.packageManager
        
        val intent = Intent(Intent.ACTION_MAIN, null)
        intent.addCategory(Intent.CATEGORY_LAUNCHER)

        val apps = packageManager.queryIntentActivities(intent, 0)

        for (resolveInfo in apps) {
            val activityInfo = resolveInfo.activityInfo
            val appName = resolveInfo.loadLabel(packageManager).toString()
            val packageName = activityInfo.packageName

            val alreadyExists = appsList.any { it["packageName"] == packageName }
            
            if (!alreadyExists) {
                // Fetch and convert icon to ByteArray
                val iconBytes = getIconBytes(packageName)
                
                val appMap = mapOf(
                    "appName" to appName,
                    "packageName" to packageName,
                    "icon" to iconBytes // This is passed as Uint8List to Flutter
                )
                appsList.add(appMap)
            }
        }
        
        appsList.sortBy { it["appName"] as String }
        return appsList
    }

    private fun getIconBytes(packageName: String): ByteArray? {
        return try {
            val drawable = context.packageManager.getApplicationIcon(packageName)
            
            // Define a standard size for the dashboard icons to save memory
            val targetSize = 100 
            val bitmap = Bitmap.createBitmap(targetSize, targetSize, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            
            // This handles both BitmapDrawable and AdaptiveIconDrawable correctly
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)

            val stream = ByteArrayOutputStream()
            // Use JPEG with 80% quality to significantly reduce data size if icons are still missing
            // or keep PNG for transparency if you have few apps.
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            stream.toByteArray()
        } catch (e: Exception) {
            Log.e("UsageMonitor", "Failed to load icon for $packageName: ${e.message}")
            null
        }
    }
}