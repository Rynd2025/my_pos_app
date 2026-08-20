import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/repositories/sync_repository.dart';
import 'sync_event.dart';
import 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncRepository syncRepository;

  SyncBloc({required this.syncRepository}) : super(const SyncState()) {
    on<SyncStarted>(_onSyncStarted);
    on<RestoreRequested>(_onRestoreRequested);
  }

  Future<void> _onSyncStarted(SyncStarted event, Emitter<SyncState> emit) async {
    emit(const SyncState(status: SyncStatus.loading));
    
    // 1. Push
    final pushResult = await syncRepository.pushOutbox();
    if (pushResult.isLeft()) {
      emit(SyncState(status: SyncStatus.error, message: (pushResult as Left).value.message));
      return;
    }

    // 2. Pull
    final pullResult = await syncRepository.pullUpdates();
    pullResult.fold(
      (failure) => emit(SyncState(status: SyncStatus.error, message: failure.message)),
      (_) => emit(const SyncState(status: SyncStatus.success)),
    );
  }

  Future<void> _onRestoreRequested(RestoreRequested event, Emitter<SyncState> emit) async {
    emit(const SyncState(status: SyncStatus.loading));
    final result = await syncRepository.restoreShop();
    result.fold(
      (failure) => emit(SyncState(status: SyncStatus.error, message: failure.message)),
      (_) => emit(const SyncState(status: SyncStatus.success)),
    );
  }
}
