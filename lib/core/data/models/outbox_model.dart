import 'package:hive/hive.dart';
import '../../domain/entities/outbox.dart';

part 'outbox_model.g.dart';

@HiveType(typeId: 7)
class OutboxModel extends Outbox {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String entityType;
  @override
  @HiveField(2)
  final String entityId;
  @HiveField(3)
  final int operationIndex;
  @override
  @HiveField(4)
  final DateTime createdAt;

  const OutboxModel({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operationIndex,
    required this.createdAt,
  }) : super(
          id: id,
          entityType: entityType,
          entityId: entityId,
          operation: OutboxOperation.upsert, // Placeholder for super
          createdAt: createdAt,
        );

  factory OutboxModel.fromEntity(Outbox outbox) {
    return OutboxModel(
      id: outbox.id,
      entityType: outbox.entityType,
      entityId: outbox.entityId,
      operationIndex: outbox.operation.index,
      createdAt: outbox.createdAt,
    );
  }

  Outbox toEntity() {
    return Outbox(
      id: id,
      entityType: entityType,
      entityId: entityId,
      operation: OutboxOperation.values[operationIndex],
      createdAt: createdAt,
    );
  }
}
