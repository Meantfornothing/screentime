// lib/features/app_management/data/datasources/mock_app_usage_data_source.dart

import 'app_usage_local_data_source.dart';

class MockAppUsageDataSourceImpl implements AppUsageDataSource {
  @override
  Future<Map<String, Duration>> getDailyUsage() async {
    // Fictional usage times for a "heavy user" scenario
    return {
      'com.social.instagram': const Duration(hours: 3, minutes: 45),
      'com.social.tiktok': const Duration(hours: 2, minutes: 10),
      'com.productivity.notion': const Duration(minutes: 15),
      //'com.productivity.slack': const Duration(minutes: 40),
      'com.entertainment.netflix': const Duration(hours: 1, minutes: 30),
      //'com.health.strava': const Duration(minutes: 25),
    };
  }
}