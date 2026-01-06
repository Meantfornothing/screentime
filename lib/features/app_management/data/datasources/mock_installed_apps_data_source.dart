// lib/features/app_management/data/datasources/mock_installed_apps_data_source.dart

import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../../domain/entities/installed_app_entity.dart';
import 'installed_apps_data_source.dart';

class MockInstalledAppsDataSourceImpl implements InstalledAppsDataSource {
  
  // Säker laddning av assets
  Future<Uint8List?> _getAssetBytes(String path) async {
    try {
      final ByteData data = await rootBundle.load(path);
      return data.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<InstalledApp>> getInstalledAppsFromOS() async {
    // Ladda ikoner för de appar som faktiskt har bilder i assets
    final instagramIcon = await _getAssetBytes('assets/icons/instagram.png');
    final tiktokIcon = await _getAssetBytes('assets/icons/tiktok.png');
    final notionIcon = await _getAssetBytes('assets/icons/notion.png');
    final netflixIcon = await _getAssetBytes('assets/icons/netflix.png');

    return [
      InstalledApp(
        packageName: 'com.social.instagram', 
        name: 'Instagram', 
        iconBytes: instagramIcon,
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
      // Här sätter vi iconBytes till null direkt för att undvika onödiga anrop
      InstalledApp(
        packageName: 'com.relax.calm', 
        name: 'Calm', 
        iconBytes: null, // Kommer visa default-ikonen automatiskt
      ),
      InstalledApp(
        packageName: 'com.android.settings', 
        name: 'Settings', 
        iconBytes: null, // Kommer visa default-ikonen automatiskt
      ),
    ];
  }
}