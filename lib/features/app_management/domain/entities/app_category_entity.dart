import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 0) // typeId 0 is unique to this entity
class AppCategoryEntity extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;

  AppCategoryEntity({
    required this.id,
    required this.name,
  });

  /// Allows creating a new instance with some updated fields.
  AppCategoryEntity copyWith({
    String? id,
    String? name,
  }) {
    return AppCategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  List<Object?> get props => [id, name];
}

/// Manual Hive Adapter to match the pattern in your other entities.
class AppCategoryEntityAdapter extends TypeAdapter<AppCategoryEntity> {
  @override
  final int typeId = 0;

  @override
  AppCategoryEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppCategoryEntity(
      id: fields[0] as String,
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AppCategoryEntity obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }
}