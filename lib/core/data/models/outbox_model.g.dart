// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbox_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OutboxModelAdapter extends TypeAdapter<OutboxModel> {
  @override
  final int typeId = 7;

  @override
  OutboxModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OutboxModel(
      id: fields[0] as String,
      entityType: fields[1] as String,
      entityId: fields[2] as String,
      operationIndex: fields[3] as int,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, OutboxModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.entityType)
      ..writeByte(2)
      ..write(obj.entityId)
      ..writeByte(3)
      ..write(obj.operationIndex)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutboxModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
