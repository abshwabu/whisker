// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cat_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CatStateAdapter extends TypeAdapter<CatState> {
  @override
  final int typeId = 0;

  @override
  CatState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CatState(
      id: fields[0] as String,
      name: fields[1] as String,
      bondLevel: fields[2] as int,
      accessoriesUnlocked: (fields[3] as List?)?.cast<String>(),
      equippedAccessory: fields[4] as String?,
      lastInteractionDate: fields[5] as DateTime?,
      currentStreak: fields[6] as int,
      longestStreak: fields[7] as int,
      adoptedDate: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CatState obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.bondLevel)
      ..writeByte(3)
      ..write(obj.accessoriesUnlocked)
      ..writeByte(4)
      ..write(obj.equippedAccessory)
      ..writeByte(5)
      ..write(obj.lastInteractionDate)
      ..writeByte(6)
      ..write(obj.currentStreak)
      ..writeByte(7)
      ..write(obj.longestStreak)
      ..writeByte(8)
      ..write(obj.adoptedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
