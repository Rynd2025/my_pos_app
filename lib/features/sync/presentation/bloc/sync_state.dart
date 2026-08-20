import 'package:equatable/equatable.dart';

enum SyncStatus { initial, loading, success, error }

class SyncState extends Equatable {
  final SyncStatus status;
  final String? message;

  const SyncState({this.status = SyncStatus.initial, this.message});

  @override
  List<Object?> get props => [status, message];
}
