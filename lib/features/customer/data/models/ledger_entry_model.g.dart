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
      paymentId: fields[7] as String?,
      ticketNumber: fields[8] as String?,
      balanceAfter: fields[9] as int,
      updatedAt: fields[10] as DateTime?,
      isDeleted: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LedgerEntryModel obj) {
    writer
      ..writeByte(12)
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
      ..write(obj.balanceAfter)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.isDeleted);
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

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LedgerEntryModel _$LedgerEntryModelFromJson(Map<String, dynamic> json) =>
    LedgerEntryModel(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      saleId: json['saleId'] as String?,
      typeIndex: (json['typeIndex'] as num).toInt(),
      amountMillimes: (json['amountMillimes'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      note: json['note'] as String?,
      paymentId: json['paymentId'] as String?,
      ticketNumber: json['ticketNumber'] as String?,
      balanceAfter: (json['balanceAfter'] as num).toInt(),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$LedgerEntryModelToJson(LedgerEntryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'saleId': instance.saleId,
      'typeIndex': instance.typeIndex,
      'amountMillimes': instance.amountMillimes,
      'createdAt': instance.createdAt.toIso8601String(),
      'note': instance.note,
      'paymentId': instance.paymentId,
      'ticketNumber': instance.ticketNumber,
      'balanceAfter': instance.balanceAfter,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };
