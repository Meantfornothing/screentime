import 'package:flutter/services.dart';
import '../../domain/entities/installed_app_entity.dart';
import 'dart:typed_data';

abstract class InstalledAppsDataSource {
  Future<List<InstalledApp>> getInstalledAppsFromOS();
}

class InstalledAppsDataSourceImpl implements InstalledAppsDataSource {
  // This channel name must match the one in your Kotlin MainActivity
  static const MethodChannel _channel = MethodChannel('com.screentime/usage_monitor');

  @override
  Future<List<InstalledApp>> getInstalledAppsFromOS() async {
    try {
      final List<dynamic> rawData = await _channel.invokeMethod('getInstalledApps');
      
      return rawData.map((data) {
        final map = Map<String, dynamic>.from(data);
        return InstalledApp(
          packageName: map['packageName'] ?? '',
          name: map['appName'] ?? 'Unknown App',
          iconBytes: map['icon'], // Map the bytes here
          assignedCategoryName: null, 
        );
      }).toList();
      
    } on PlatformException catch (e) {
      print("Failed to get installed apps: '${e.message}'.");
      return [];
    }
  }
}