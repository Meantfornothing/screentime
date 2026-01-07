// lib/features/app_management/domain/entities/user_settings_entity.dart

import 'package:hive/hive.dart';

@HiveType(typeId: 2) 
class UserSettingsEntity extends HiveObject {
  // Descriptive Goal Constants
  static const String goalWorktool = 'Use my phone as a worktool, not a distraction';
  static const String goalProductivePrecedence = 'Let productive apps take more place than other apps';
  static const String goalSocial = 'Use my phone to strengthen relations with others';
  static const String goalEntertainment = 'Use my phone as an entertainment device';
  static const String goalRelaxingContent = 'Consume content I find relaxing';
  static const String goalReduceStress = 'Use my phone to reduce stress';

  static const List<String> allGoals = [
    goalWorktool,
    goalProductivePrecedence,
    goalSocial,
    goalEntertainment,
    goalRelaxingContent,
    goalReduceStress,
  ];

  // lib/features/app_management/domain/entities/user_settings_entity.dart

  // Inside the UserSettingsEntity class:
  static String getGoalDescription(String goal) {
    switch (goal) {
      case goalWorktool:
        return "Focus on utility. We'll prioritize work apps and minimize distractions.";
      case goalProductivePrecedence:
        return "A balanced approach where productivity apps take the lead.";
      case goalSocial:
        return "Helpful reminders to stay connected without getting lost in feeds.";
      case goalEntertainment:
        return "Turn your phone into a dedicated media and gaming device.";
      case goalRelaxingContent:
      case goalReduceStress:
        return "Emphasis on audiobooks, puzzles, and calm Swedish content.";
      default:
        return "Personalize your phone's behavior to match your day.";
    }
  }
  @HiveField(0) final double breakReminderFrequency; 
  @HiveField(1) final int dailyScreenTimeGoalMinutes; 
  @HiveField(2) final double nudgeIntensity; 
  @HiveField(3) final int bedtimeHour; 
  @HiveField(4) final int bedtimeMinute;
  @HiveField(5) final String userGoal; 

  UserSettingsEntity({
    this.breakReminderFrequency = 0.5,
    this.dailyScreenTimeGoalMinutes = 360,
    this.nudgeIntensity = 0.5,
    this.bedtimeHour = 23,
    this.bedtimeMinute = 0,
    this.userGoal = goalWorktool, 
  });

  UserSettingsEntity copyWith({
    double? breakReminderFrequency,
    int? dailyScreenTimeGoalMinutes,
    double? nudgeIntensity,
    int? bedtimeHour,
    int? bedtimeMinute,
    String? userGoal,
  }) {
    return UserSettingsEntity(
      breakReminderFrequency: breakReminderFrequency ?? this.breakReminderFrequency,
      dailyScreenTimeGoalMinutes: dailyScreenTimeGoalMinutes ?? this.dailyScreenTimeGoalMinutes,
      nudgeIntensity: nudgeIntensity ?? this.nudgeIntensity,
      bedtimeHour: bedtimeHour ?? this.bedtimeHour,
      bedtimeMinute: bedtimeMinute ?? this.bedtimeMinute,
      userGoal: userGoal ?? this.userGoal,
    );
  }
}

// Manual Adapter Implementation - Ensure this is outside the class
class UserSettingsEntityAdapter extends TypeAdapter<UserSettingsEntity> {
  @override
  final int typeId = 2;

  @override
  UserSettingsEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettingsEntity(
      breakReminderFrequency: fields[0] as double,
      dailyScreenTimeGoalMinutes: fields[1] as int,
      nudgeIntensity: fields[2] as double,
      bedtimeHour: fields[3] as int,
      bedtimeMinute: fields[4] as int,
      userGoal: fields[5] as String? ?? UserSettingsEntity.goalWorktool,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettingsEntity obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)..write(obj.breakReminderFrequency)
      ..writeByte(1)..write(obj.dailyScreenTimeGoalMinutes)
      ..writeByte(2)..write(obj.nudgeIntensity)
      ..writeByte(3)..write(obj.bedtimeHour)
      ..writeByte(4)..write(obj.bedtimeMinute)
      ..writeByte(5)..write(obj.userGoal);
  }
}
