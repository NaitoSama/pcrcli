// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 0;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings()
      ..getIndex = (fields[0] as Map).cast<String, int>()
      ..isDarkMode = fields[1] as bool
      ..isUrlConfirmed = fields[2] as bool
      ..isLoggedIn = fields[3] as bool
      ..remoteServerUrl = fields[4] as String
      ..username = fields[5] as String
      ..authority = fields[6] as int
      ..token = fields[7] as String;
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.getIndex)
      ..writeByte(1)
      ..write(obj.isDarkMode)
      ..writeByte(2)
      ..write(obj.isUrlConfirmed)
      ..writeByte(3)
      ..write(obj.isLoggedIn)
      ..writeByte(4)
      ..write(obj.remoteServerUrl)
      ..writeByte(5)
      ..write(obj.username)
      ..writeByte(6)
      ..write(obj.authority)
      ..writeByte(7)
      ..write(obj.token);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
