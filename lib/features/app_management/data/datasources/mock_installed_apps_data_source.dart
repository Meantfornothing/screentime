// lib/features/app_management/data/datasources/mock_installed_apps_data_source.dart


import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../../domain/entities/installed_app_entity.dart';
import 'installed_apps_data_source.dart';


class MockInstalledAppsDataSourceImpl implements InstalledAppsDataSource {
 
  // Helper för att ladda ikoner från assets (om de finns)
  Future<Uint8List?> _getSafeAssetBytes(String path) async {
    try {
      final ByteData data = await rootBundle.load(path);
      return data.buffer.asUint8List();
    } catch (e) {
      // Returnerar null om filen saknas för att inte krascha appen
      return null;
    }
  }


  @override
  Future<List<InstalledApp>> getInstalledAppsFromOS() async {
    // Ladda ikoner från assets
    final instagramIcon = await _getSafeAssetBytes('assets/icons/instagram.png');
    final facebookIcon = await _getSafeAssetBytes('assets/icons/facebook.png');
    final svtplayIcon = await _getSafeAssetBytes('assets/icons/svtplay.png');
    final googleIcon = await _getSafeAssetBytes('assets/icons/google.png');
    final youtubeIcon = await _getSafeAssetBytes('assets/icons/youtube.png');
    final messengerIcon = await _getSafeAssetBytes('assets/icons/messenger.png');
    final telefonIcon = await _getSafeAssetBytes('assets/icons/phone.png');
    final storytelIcon = await _getSafeAssetBytes('assets/icons/storytel.png');
    final svdkorsordIcon = await _getSafeAssetBytes('assets/icons/svdkorsord.png');
    final bankidIcon = await _getSafeAssetBytes('assets/icons/bankid.png');
    final vaderIcon = await _getSafeAssetBytes('assets/icons/vader.png');

    // Returnera listan med tilldelade ikoner för Marias profil
    return [
      InstalledApp(
        packageName: 'com.facebook.katana',
        name: 'Facebook',
        iconBytes: facebookIcon,
      ),
      InstalledApp(
        packageName: 'com.instagram.android',
        name: 'Instagram',
        iconBytes: instagramIcon,
      ),
      InstalledApp(
        packageName: 'se.svt.play',
        name: 'SVT Play',
        iconBytes: svtplayIcon,
      ),
      InstalledApp(
        packageName: 'com.google.android.googlequicksearchbox',
        name: 'Google',
        iconBytes: googleIcon,
      ),
      InstalledApp(
        packageName: 'com.google.android.youtube',
        name: 'YouTube',
        iconBytes: youtubeIcon,
      ),
      InstalledApp(
        packageName: 'com.facebook.orca',
        name: 'Messenger',
        iconBytes: messengerIcon,
      ),
      InstalledApp(
        packageName: 'com.android.server.telecom',
        name: 'Telefon',
        iconBytes: telefonIcon,
      ),
      InstalledApp(
        packageName: 'com.storytel.storytel',
        name: 'Storytel',
        iconBytes: storytelIcon,
      ),
      InstalledApp(
        packageName: 'se.svd.korsord',
        name: 'SVD Korsord',
        iconBytes: svdkorsordIcon,
      ),
      InstalledApp(
        packageName: 'com.bankid.mobile',
        name: 'Bank-ID',
        iconBytes: bankidIcon,
      ),
      InstalledApp(
        packageName: 'se.smhi.smhi',
        name: 'Väder',
        iconBytes: vaderIcon,
      ),
    ];
  }
}
