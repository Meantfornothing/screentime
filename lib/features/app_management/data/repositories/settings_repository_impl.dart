import 'package:hive/hive.dart';
import '../../domain/repositories/settings_repository_interface.dart';
import '../../domain/entities/user_settings_entity.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final Box<UserSettingsEntity> settingsBox;

  SettingsRepositoryImpl(this.settingsBox);

  @override
  Future<UserSettingsEntity> getSettings() async {
    if (settingsBox.isEmpty) {
      final defaultSettings = UserSettingsEntity();
      await settingsBox.put('user_settings', defaultSettings);
      return defaultSettings;
    }
    return settingsBox.get('user_settings')!;
  }

  @override
  Future<void> saveSettings(UserSettingsEntity settings) async {
    await settingsBox.put('user_settings', settings);
  }
}