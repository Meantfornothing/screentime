import 'package:hive/hive.dart';

@HiveType(typeId: 2) 
class UserSettingsEntity extends HiveObject {
  @HiveField(0)
  final double breakReminderFrequency; 

  @HiveField(1)
  final int dailyScreenTimeGoalMinutes; 

  @HiveField(2)
  final double nudgeIntensity; 

  @HiveField(3)
  final int bedtimeHour; 

  @HiveField(4)
  final int bedtimeMinute;

  // NEW: User's primary goal
  @HiveField(5)
  final String userGoal; 

  UserSettingsEntity({
    this.breakReminderFrequency = 0.5,
    this.dailyScreenTimeGoalMinutes = 360,
    this.nudgeIntensity = 0.5,
    this.bedtimeHour = 23,
    this.bedtimeMinute = 0,
    this.userGoal = 'Reduce Screen Time', // Default
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
      userGoal: fields[5] as String? ?? 'Reduce Screen Time', // Handle missing field for existing data
    );
  }

  @override
  void write(BinaryWriter writer, UserSettingsEntity obj) {
    writer
      ..writeByte(6) // Update count
      ..writeByte(0)
      ..write(obj.breakReminderFrequency)
      ..writeByte(1)
      ..write(obj.dailyScreenTimeGoalMinutes)
      ..writeByte(2)
      ..write(obj.nudgeIntensity)
      ..writeByte(3)
      ..write(obj.bedtimeHour)
      ..writeByte(4)
      ..write(obj.bedtimeMinute)
      ..writeByte(5) // New field
      ..write(obj.userGoal);
  }
}