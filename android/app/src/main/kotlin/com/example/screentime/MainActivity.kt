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
import android.content.pm.PackageManager
import android.os.Handler
import android.os.Looper
import java.util.concurrent.Executors

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.screentime/usage_monitor"
    private val executor = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getInstalledApps") {
                executor.execute {
                    try {
                        // Limit to 100 apps to keep the MethodChannel payload safe
                        val apps = getInstalledApps(limit = 100)
                        Handler(Looper.getMainLooper()).post {
                            result.success(apps)
                        }
                    } catch (e: Exception) {
                        Handler(Looper.getMainLooper()).post {
                            result.error("UNAVAILABLE", "Failed to fetch apps: ${e.message}", null)
                        }
                    }
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getInstalledApps(limit: Int): List<Map<String, Any?>> {
        val appsList = mutableListOf<Map<String, Any?>>()
        val pm = applicationContext.packageManager
        
        val intent = Intent(Intent.ACTION_MAIN, null)
        intent.addCategory(Intent.CATEGORY_LAUNCHER)

        val apps = pm.queryIntentActivities(intent, 0)

        for (resolveInfo in apps) {
            if (appsList.size >= limit) break
            val activityInfo = resolveInfo.activityInfo
            val packageName = activityInfo.packageName
            
            if (appsList.none { it["packageName"] == packageName }) {
                try {
                    val appName = resolveInfo.loadLabel(pm).toString()
                    val iconBytes = getIconBytes(packageName)
                    
                    val appMap = mapOf(
                        "appName" to appName,
                        "packageName" to packageName,
                        "icon" to iconBytes 
                    )
                    appsList.add(appMap)
                } catch (e: Exception) {
                    Log.e("UsageMonitor", "Skipping $packageName: ${e.message}")
                }
            }
        }
        appsList.sortBy { it["appName"] as String }
        return appsList
    }

    private fun getIconBytes(packageName: String): ByteArray? {
        return try {
            val pm = applicationContext.packageManager
            val drawable = pm.getApplicationIcon(packageName)
            
            // 48x48 is the standard size for list icons
            val targetSize = 48 
            val bitmap = Bitmap.createBitmap(targetSize, targetSize, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)

            val stream = ByteArrayOutputStream()
            // CRITICAL: Using PNG to support transparency.
            // JPEG turns transparent backgrounds black, creating the "black border" issue.
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            stream.toByteArray()
        } catch (e: Exception) {
            null
        }
    }
}