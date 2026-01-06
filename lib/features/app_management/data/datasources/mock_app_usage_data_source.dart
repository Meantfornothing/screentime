// lib/features/app_management/data/datasources/mock_app_usage_data_source.dart

import 'app_usage_local_data_source.dart';

class MockAppUsageDataSourceImpl implements AppUsageDataSource {
  @override
  Future<Map<String, Duration>> getDailyUsage() async {
    // Fiktiva användningstider för att testa de nya kategorierna
    return {
      'com.social.instagram': const Duration(hours: 3, minutes: 45), // Social
      'com.social.tiktok': const Duration(hours: 2, minutes: 10),    // Social
      'com.productivity.notion': const Duration(minutes: 15),        // Productivity
      'com.entertainment.netflix': const Duration(hours: 1, minutes: 30), // Entertainment
      
      // VIKTIGT: Lägg till tider för de nya apparna vi skapade i MockCategorizationDataSource
      'com.relax.calm': const Duration(hours: 0, minutes: 45),       // Relaxation
      'com.android.settings': const Duration(hours: 0, minutes: 12), // Neutral
    };
  }
}