// lib/features/app_management/data/datasources/mock_installed_apps_data_source.dart

import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../../domain/entities/installed_app_entity.dart';
import 'installed_apps_data_source.dart';

class MockInstalledAppsDataSourceImpl implements InstalledAppsDataSource {
  
  // Helper för att ladda mock-ikoner från assets
  Future<Uint8List> _getAssetBytes(String path) async {
    try {
      final ByteData data = await rootBundle.load(path);
      return data.buffer.asUint8List();
    } catch (e) {
      // Returnera tom lista om bilden saknas så att appen inte kraschar
      return Uint8List(0);
    }
  }

  @override
  Future<List<InstalledApp>> getInstalledAppsFromOS() async {
    // Ladda ikoner för de befintliga mock-apparna
    final instagramIcon = await _getAssetBytes('assets/icons/instagram.png');
    final tiktokIcon = await _getAssetBytes('assets/icons/tiktok.png');
    final notionIcon = await _getAssetBytes('assets/icons/notion.png');
    final netflixIcon = await _getAssetBytes('assets/icons/netflix.png');
    
    // NYTT: Ikoner för dina nya kategorier (Se till att dessa filer finns i assets)
    // Om du inte har bilderna än kan du använda en placeholder eller tom Uint8List(0)
    final calmIcon = await _getAssetBytes('assets/icons/calm.png');
    final settingsIcon = await _getAssetBytes('assets/icons/settings.png');

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
      // LÄGG TILL DESSA: Måste matcha packageName i din MockCategorizationLocalDataSource
      InstalledApp(
        packageName: 'com.relax.calm', 
        name: 'Calm', 
        iconBytes: calmIcon,
      ),
      InstalledApp(
        packageName: 'com.android.settings', 
        name: 'Settings', 
        iconBytes: settingsIcon,
      ),
    ];
  }
}