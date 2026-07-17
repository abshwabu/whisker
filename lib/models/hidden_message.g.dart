// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hidden_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiddenMessageAdapter extends TypeAdapter<HiddenMessage> {
  @override
  final int typeId = 2;

  @override
  HiddenMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiddenMessage(
      bondLevelRequired: fields[0] as int,
      text: fields[1] as String,
      imagePath: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HiddenMessage obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.bondLevelRequired)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiddenMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
