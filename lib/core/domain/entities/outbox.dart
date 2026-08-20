import 'package:equatable/equatable.dart';

enum OutboxOperation { upsert, delete }

class Outbox extends Equatable {
  final String id;
  final String entityType;
  final String entityId;
  final OutboxOperation operation;
  final DateTime createdAt;

  const Outbox({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, entityType, entityId, operation, createdAt];
}
