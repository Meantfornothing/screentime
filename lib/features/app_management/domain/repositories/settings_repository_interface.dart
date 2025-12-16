import '../entities/user_settings_entity.dart';

abstract class SettingsRepository {
  Future<UserSettingsEntity> getSettings();
  Future<void> saveSettings(UserSettingsEntity settings);
}