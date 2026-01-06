// lib/features/app_management/data/datasources/mock_app_usage_data_source.dart
import 'app_usage_local_data_source.dart';


class MockAppUsageDataSourceImpl implements AppUsageDataSource {
  @override
  Future<Map<String, Duration>> getDailyUsage() async {
    return {
      'com.facebook.katana': const Duration(minutes: 98),
      'com.instagram.android': const Duration(minutes: 57),
      'se.svt.play': const Duration(minutes: 82),
      'com.google.android.googlequicksearchbox': const Duration(minutes: 12),
      'com.google.android.youtube': const Duration(minutes: 36),
      'com.facebook.orca': const Duration(minutes: 21),
      'com.android.server.telecom': const Duration(minutes: 18),
      'com.storytel.storytel': const Duration(minutes: 61),
      'se.svd.korsord': const Duration(minutes: 43),
      'com.bankid.mobile': const Duration(minutes: 2),
      'se.smhi.smhi': const Duration(minutes: 4),
    };
  }
}
