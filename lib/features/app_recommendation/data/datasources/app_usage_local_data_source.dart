import 'package:app_usage/app_usage.dart';

abstract class AppUsageDataSource {
  Future<Map<String, Duration>> getDailyUsage();
}

class AppUsageDataSourceImpl implements AppUsageDataSource {
  @override
  Future<Map<String, Duration>> getDailyUsage() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(const Duration(hours: 24));
      
      // Fetch from plugin
      List<AppUsageInfo> infoList = await AppUsage().getAppUsage(startDate, endDate);
      
      // Map PackageName -> Duration
      final Map<String, Duration> usageMap = {};
      for (var info in infoList) {
        usageMap[info.packageName] = info.usage;
      }
      return usageMap;
    } catch (e) {
      print("Usage Stats Error: $e"); // Likely permission denied
      return {};
    }
  }
}