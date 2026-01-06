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

    final instagramIcon = await _getSafeAssetBytes('assets/icons/instagram.png');
    final facebookIcon = await _getSafeAssetBytes('assets/icons/facebook.png');
    final svtplayIcon = await _getSafeAssetBytes('assets/icons/svtplay.png');
    final googleIcon = await _getSafeAssetBytes('assets/icons/google.png');
    final youtubeIcon = await _getSafeAssetBytes('assets/icons/youtube.png');
    final messengerIcon = await _getSafeAssetBytes('assets/icons/messenger.png');
    final telefonIcon = await _getSafeAssetBytes('assets/icons/telefon.png');
    final storytelIcon = await _getSafeAssetBytes('assets/icons/storytel.png');
    final svdkorsordIcon = await _getSafeAssetBytes('assets/icons/svdkorsord.png');
    final bankidIcon = await _getSafeAssetBytes('assets/icons/bankid.png');
    final vaderIcon = await _getSafeAssetBytes('assets/icons/vader.png');
    // Här definieras alla appar som systemet ska tro är installerade för Marias profil
    return [
      InstalledApp(
        packageName: 'com.facebook.katana',
        name: 'Facebook',
        iconBytes: null,
      ),
      InstalledApp(
        packageName: 'com.instagram.android',
        name: 'Instagram',
        iconBytes: instagramIcon,
      ),
      InstalledApp(
        packageName: 'se.svt.play',
        name: 'SVT Play',
        iconBytes: null,
      ),
      InstalledApp(
        packageName: 'com.google.android.googlequicksearchbox',
        name: 'Google',
        iconBytes: null,
      ),
      InstalledApp(
        packageName: 'com.google.android.youtube',
        name: 'YouTube',
        iconBytes: null,
      ),
      InstalledApp(
        packageName: 'com.facebook.orca',
        name: 'Messenger',
        iconBytes: null,
      ),
      InstalledApp(
        packageName: 'com.android.server.telecom',
        name: 'Telefon',
        iconBytes: null,
      ),
      InstalledApp(
        packageName: 'com.storytel.storytel',
        name: 'Storytel',
        iconBytes: null,
      ),
      InstalledApp(
        packageName: 'se.svd.korsord',
        name: 'SVD Korsord',
        iconBytes: null,
      ),
      InstalledApp(
        packageName: 'com.bankid.mobile',
        name: 'Bank-ID',
        iconBytes: null,
      ),
      InstalledApp(
        packageName: 'se.smhi.smhi',
        name: 'Väder',
        iconBytes: null,
      ),
    ];
  }
}
