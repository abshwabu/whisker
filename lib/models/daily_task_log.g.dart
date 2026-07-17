// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_task_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyTaskLogAdapter extends TypeAdapter<DailyTaskLog> {
  @override
  final int typeId = 1;

  @override
  DailyTaskLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyTaskLog(
      date: fields[0] as DateTime,
      feedDone: fields[1] as bool,
      playDone: fields[2] as bool,
      brushDone: fields[3] as bool,
      cuddleDone: fields[4] as bool,
      noteUnlocked: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyTaskLog obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.feedDone)
      ..writeByte(2)
      ..write(obj.playDone)
      ..writeByte(3)
      ..write(obj.brushDone)
      ..writeByte(4)
      ..write(obj.cuddleDone)
      ..writeByte(5)
      ..write(obj.noteUnlocked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyTaskLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
