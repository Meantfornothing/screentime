import 'package:hive/hive.dart';

// 1. Annotate the class (Optional if manual, but good practice)
@HiveType(typeId: 0)
class AppCategoryEntity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  AppCategoryEntity({required this.id, required this.name});
}

// 2. Manual TypeAdapter Implementation
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