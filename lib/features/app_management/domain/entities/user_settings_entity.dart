import 'package:hive/hive.dart';

@HiveType(typeId: 2) // Ensure unique ID (0 is Category, 1 is InstalledApp)
class UserSettingsEntity extends HiveObject {
  @HiveField(0)
  final double breakReminderFrequency; // 0.0 to 1.0

  @HiveField(1)
  final int dailyScreenTimeGoalMinutes; // in minutes

  @HiveField(2)
  final double nudgeIntensity; // 0.0 to 1.0

  @HiveField(3)
  final int bedtimeHour; 

  @HiveField(4)
  final int bedtimeMinute;

  UserSettingsEntity({
    this.breakReminderFrequency = 0.5,
    this.dailyScreenTimeGoalMinutes = 360, // 6 hours default
    this.nudgeIntensity = 0.5,
    this.bedtimeHour = 23,
    this.bedtimeMinute = 0,
  });

  UserSettingsEntity copyWith({
    double? breakReminderFrequency,
    int? dailyScreenTimeGoalMinutes,
    double? nudgeIntensity,
    int? bedtimeHour,
    int? bedtimeMinute,
  }) {
    return UserSettingsEntity(
      breakReminderFrequency: breakReminderFrequency ?? this.breakReminderFrequency,
      dailyScreenTimeGoalMinutes: dailyScreenTimeGoalMinutes ?? this.dailyScreenTimeGoalMinutes,
      nudgeIntensity: nudgeIntensity ?? this.nudgeIntensity,
      bedtimeHour: bedtimeHour ?? this.bedtimeHour,
      bedtimeMinute: bedtimeMinute ?? this.bedtimeMinute,
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
    );
  }

  @override
  void write(BinaryWriter writer, UserSettingsEntity obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.breakReminderFrequency)
      ..writeByte(1)
      ..write(obj.dailyScreenTimeGoalMinutes)
      ..writeByte(2)
      ..write(obj.nudgeIntensity)
      ..writeByte(3)
      ..write(obj.bedtimeHour)
      ..writeByte(4)
      ..write(obj.bedtimeMinute);
  }
}