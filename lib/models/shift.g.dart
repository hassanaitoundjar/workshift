// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShiftAdapter extends TypeAdapter<Shift> {
  @override
  final int typeId = 3;

  @override
  Shift read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Shift(
      id: fields[0] as String,
      employeeId: fields[1] as String,
      clientId: fields[2] as String?,
      date: fields[3] as DateTime,
      shiftType: fields[4] as ShiftType,
      advanceMoney: fields[5] as double,
      notes: fields[6] as String?,
      isConfirmed: fields[7] as bool,
      createdAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Shift obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.employeeId)
      ..writeByte(2)
      ..write(obj.clientId)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.shiftType)
      ..writeByte(5)
      ..write(obj.advanceMoney)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.isConfirmed)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ShiftTypeAdapter extends TypeAdapter<ShiftType> {
  @override
  final int typeId = 2;

  @override
  ShiftType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ShiftType.morning;
      case 1:
        return ShiftType.allDay;
      case 2:
        return ShiftType.afternoon;
      case 3:
        return ShiftType.off;
      default:
        return ShiftType.morning;
    }
  }

  @override
  void write(BinaryWriter writer, ShiftType obj) {
    switch (obj) {
      case ShiftType.morning:
        writer.writeByte(0);
        break;
      case ShiftType.allDay:
        writer.writeByte(1);
        break;
      case ShiftType.afternoon:
        writer.writeByte(2);
        break;
      case ShiftType.off:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
