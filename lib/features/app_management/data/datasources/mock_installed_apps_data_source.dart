// lib/features/app_management/data/datasources/mock_installed_apps_data_source.dart

import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../../domain/entities/installed_app_entity.dart';
import 'installed_apps_data_source.dart';


class MockInstalledAppsDataSourceImpl implements InstalledAppsDataSource {
  
  // Helper to load assets
  Future<Uint8List> _getAssetBytes(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  @override
  Future<List<InstalledApp>> getInstalledAppsFromOS() async {
    // Load real icons for the fictional apps
    final instagramIcon = await _getAssetBytes('assets/icons/instagram.png');
    final tiktokIcon = await _getAssetBytes('assets/icons/tiktok.png');
    final notionIcon = await _getAssetBytes('assets/icons/notion.png');
    final netflixIcon = await _getAssetBytes('assets/icons/netflix.png');

    return [
      InstalledApp(
        packageName: 'com.social.instagram', 
        name: 'Instagram', 
        iconBytes: instagramIcon, // Icon belongs here
      ),
      InstalledApp(
        packageName: 'com.social.tiktok', 
        name: 'TikTok', 
        iconBytes: tiktokIcon,
      ),
      InstalledApp(
        packageName: 'com.productivity.notion', 
        name: 'Notion', 
        iconBytes: notionIcon,
      ),
      InstalledApp(
        packageName: 'com.entertainment.netflix', 
        name: 'Netflix', 
        iconBytes: netflixIcon,
      ),
    ];
  }
}