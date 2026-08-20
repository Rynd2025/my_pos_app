import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../features/sync/domain/repositories/sync_repository.dart';
import '../service_locator.dart';

class SyncService {
  Timer? _timer;
  Timer? _debounce;
  bool _isSyncing = false;

  void startAutoSync() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      sync();
    });
  }

  void stopAutoSync() {
    _timer?.cancel();
    _debounce?.cancel();
  }

  /// Call whenever a local write queues a new outbox entry. Debounced so a
  /// single sale (which queues several entries in quick succession) doesn't
  /// trigger a burst of overlapping sync attempts — just one, shortly after
  /// things settle. Safe to call with no internet: sync() swallows failures.
  void notifyLocalChange() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), sync);
  }

  Future<void> sync() async {
    if (_isSyncing) return;
    _isSyncing = true;
    
    try {
      final syncRepo = sl<SyncRepository>();
      
      // 1. Push
      await syncRepo.pushOutbox();
      
      // 2. Pull
      await syncRepo.pullUpdates();
      
      debugPrint('Sync completed successfully');
    } catch (e) {
      debugPrint('Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }
}
