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
  @override
  @HiveField(5, defaultValue: 0)
  final int retryCount;
  @override
  @HiveField(6)
  final String? lastError;

  const OutboxModel({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operationIndex,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
  }) : super(
          id: id,
          entityType: entityType,
          entityId: entityId,
          operation: OutboxOperation.upsert, // Placeholder for super
          createdAt: createdAt,
          retryCount: retryCount,
          lastError: lastError,
        );

  factory OutboxModel.fromEntity(Outbox outbox) {
    return OutboxModel(
      id: outbox.id,
      entityType: outbox.entityType,
      entityId: outbox.entityId,
      operationIndex: outbox.operation.index,
      createdAt: outbox.createdAt,
      retryCount: outbox.retryCount,
      lastError: outbox.lastError,
    );
  }

  Outbox toEntity() {
    return Outbox(
      id: id,
      entityType: entityType,
      entityId: entityId,
      operation: OutboxOperation.values[operationIndex],
      createdAt: createdAt,
      retryCount: retryCount,
      lastError: lastError,
    );
  }
}
