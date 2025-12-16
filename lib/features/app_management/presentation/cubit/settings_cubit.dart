import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/settings_repository_interface.dart';
import '../../domain/entities/user_settings_entity.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository repository;

  SettingsCubit(this.repository) : super(SettingsState.initial());

  Future<void> loadSettings() async {
    try {
      final settings = await repository.getSettings();
      emit(state.copyWith(status: SettingsStatus.success, settings: settings));
    } catch (e) {
      emit(state.copyWith(status: SettingsStatus.failure));
    }
  }

  Future<void> updateBreakFrequency(double value) async {
    final newSettings = state.settings.copyWith(breakReminderFrequency: value);
    emit(state.copyWith(settings: newSettings));
    // Auto-save logic (or save on button press)
  }

  Future<void> updateDailyGoal(int minutes) async {
    final newSettings = state.settings.copyWith(dailyScreenTimeGoalMinutes: minutes);
    emit(state.copyWith(settings: newSettings));
  }

  Future<void> updateNudgeIntensity(double value) async {
    final newSettings = state.settings.copyWith(nudgeIntensity: value);
    emit(state.copyWith(settings: newSettings));
  }

  Future<void> updateBedtime(int hour, int minute) async {
    final newSettings = state.settings.copyWith(bedtimeHour: hour, bedtimeMinute: minute);
    emit(state.copyWith(settings: newSettings));
  }

  Future<void> saveSettings() async {
    try {
      await repository.saveSettings(state.settings);
    } catch (e) {
      // Handle error
    }
  }
}