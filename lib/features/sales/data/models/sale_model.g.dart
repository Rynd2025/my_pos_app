// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleModelAdapter extends TypeAdapter<SaleModel> {
  @override
  final int typeId = 2;

  @override
  SaleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleModel(
      id: fields[0] as String,
      ticketNumber: fields[1] as String,
      createdAt: fields[2] as DateTime,
      customerId: fields[3] as String?,
      items: (fields[4] as List).cast<SaleItemModel>(),
      totalMillimes: fields[5] as int,
      paidMillimes: fields[6] as int,
      dueMillimes: fields[7] as int,
      paymentMethodIndex: fields[8] as int,
      updatedAt: fields[9] as DateTime?,
      isDeleted: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SaleModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.ticketNumber)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.customerId)
      ..writeByte(4)
      ..write(obj.items)
      ..writeByte(5)
      ..write(obj.totalMillimes)
      ..writeByte(6)
      ..write(obj.paidMillimes)
      ..writeByte(7)
      ..write(obj.dueMillimes)
      ..writeByte(8)
      ..write(obj.paymentMethodIndex)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SaleItemModelAdapter extends TypeAdapter<SaleItemModel> {
  @override
  final int typeId = 3;

  @override
  SaleItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleItemModel(
      id: fields[0] as String,
      saleId: fields[1] as String,
      productId: fields[2] as String?,
      productName: fields[3] as String,
      quantity: fields[4] as int,
      priceAtSaleMillimes: fields[5] as int,
      purchasePriceAtSaleMillimes: fields[6] as int,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime?,
      isDeleted: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SaleItemModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.saleId)
      ..writeByte(2)
      ..write(obj.productId)
      ..writeByte(3)
      ..write(obj.productName)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.priceAtSaleMillimes)
      ..writeByte(6)
      ..write(obj.purchasePriceAtSaleMillimes)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaleModel _$SaleModelFromJson(Map<String, dynamic> json) => SaleModel(
      id: json['id'] as String,
      ticketNumber: json['ticketNumber'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      customerId: json['customerId'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => SaleItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalMillimes: (json['totalMillimes'] as num).toInt(),
      paidMillimes: (json['paidMillimes'] as num).toInt(),
      dueMillimes: (json['dueMillimes'] as num).toInt(),
      paymentMethodIndex: (json['paymentMethodIndex'] as num).toInt(),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$SaleModelToJson(SaleModel instance) => <String, dynamic>{
      'id': instance.id,
      'ticketNumber': instance.ticketNumber,
      'createdAt': instance.createdAt.toIso8601String(),
      'customerId': instance.customerId,
      'items': instance.items,
      'totalMillimes': instance.totalMillimes,
      'paidMillimes': instance.paidMillimes,
      'dueMillimes': instance.dueMillimes,
      'paymentMethodIndex': instance.paymentMethodIndex,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };

SaleItemModel _$SaleItemModelFromJson(Map<String, dynamic> json) =>
    SaleItemModel(
      id: json['id'] as String,
      saleId: json['saleId'] as String,
      productId: json['productId'] as String?,
      productName: json['productName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      priceAtSaleMillimes: (json['priceAtSaleMillimes'] as num).toInt(),
      purchasePriceAtSaleMillimes:
          (json['purchasePriceAtSaleMillimes'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$SaleItemModelToJson(SaleItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'saleId': instance.saleId,
      'productId': instance.productId,
      'productName': instance.productName,
      'quantity': instance.quantity,
      'priceAtSaleMillimes': instance.priceAtSaleMillimes,
      'purchasePriceAtSaleMillimes': instance.purchasePriceAtSaleMillimes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };
