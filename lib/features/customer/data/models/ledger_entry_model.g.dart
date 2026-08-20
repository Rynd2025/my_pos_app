// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger_entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LedgerEntryModelAdapter extends TypeAdapter<LedgerEntryModel> {
  @override
  final int typeId = 6;

  @override
  LedgerEntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LedgerEntryModel(
      id: fields[0] as String,
      customerId: fields[1] as String,
      saleId: fields[2] as String?,
      typeIndex: fields[3] as int,
      amountMillimes: fields[4] as int,
      createdAt: fields[5] as DateTime,
      note: fields[6] as String?,
      paymentId: fields[7] as String,
      ticketNumber: fields[8] as String?,
      balanceAfter: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LedgerEntryModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.saleId)
      ..writeByte(3)
      ..write(obj.typeIndex)
      ..writeByte(4)
      ..write(obj.amountMillimes)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.note)
      ..writeByte(7)
      ..write(obj.paymentId)
      ..writeByte(8)
      ..write(obj.ticketNumber)
      ..writeByte(9)
      ..write(obj.balanceAfter);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LedgerEntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
