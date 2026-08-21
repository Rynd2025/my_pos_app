import 'package:equatable/equatable.dart';

enum OutboxOperation { upsert, delete }

class Outbox extends Equatable {
  final String id;
  final String entityType;
  final String entityId;
  final OutboxOperation operation;
  final DateTime createdAt;
  // How many times a push of this item has been rejected/failed, and a
  // short description of the most recent failure. Never cleared by a
  // failure — only removed once a push actually succeeds — so a bad item
  // stays visible for inspection instead of silently vanishing.
  final int retryCount;
  final String? lastError;

  const Outbox({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
  });

  Outbox copyWith({int? retryCount, String? lastError}) {
    return Outbox(
      id: id,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  List<Object?> get props =>
      [id, entityType, entityId, operation, createdAt, retryCount, lastError];
}
