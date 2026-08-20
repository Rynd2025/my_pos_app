// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductModelAdapter extends TypeAdapter<ProductModel> {
  @override
  final int typeId = 0;

  @override
  ProductModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductModel(
      id: fields[0] as String,
      name: fields[1] as String,
      barcode: fields[2] as String?,
      price: fields[3] as double,
      purchasePrice: fields[9] as double,
      stock: fields[4] as int,
      lowStockThreshold: fields[10] as int?,
      brand: fields[5] as String?,
      category: fields[6] as String?,
      unit: fields[7] as String?,
      updatedAt: fields[11] as DateTime?,
      isDeleted: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ProductModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.barcode)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.stock)
      ..writeByte(5)
      ..write(obj.brand)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.unit)
      ..writeByte(9)
      ..write(obj.purchasePrice)
      ..writeByte(10)
      ..write(obj.lowStockThreshold)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      barcode: json['barcode'] as String?,
      price: (json['price'] as num).toDouble(),
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num).toInt(),
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt(),
      brand: json['brand'] as String?,
      category: json['category'] as String?,
      unit: json['unit'] as String?,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'barcode': instance.barcode,
      'price': instance.price,
      'stock': instance.stock,
      'brand': instance.brand,
      'category': instance.category,
      'unit': instance.unit,
      'purchasePrice': instance.purchasePrice,
      'lowStockThreshold': instance.lowStockThreshold,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isDeleted': instance.isDeleted,
    };
