import '../../domain/entities/user_settings_entity.dart';

enum SettingsStatus { loading, success, failure }

class SettingsState {
  final SettingsStatus status;
  final UserSettingsEntity settings;

  const SettingsState({
    this.status = SettingsStatus.loading,
    required this.settings,
  });
  
  // Factory for initial state
  factory SettingsState.initial() {
    return SettingsState(
      status: SettingsStatus.loading, 
      settings: UserSettingsEntity(),
    );
  }

  SettingsState copyWith({
    SettingsStatus? status,
    UserSettingsEntity? settings,
  }) {
    return SettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
    );
  }
}