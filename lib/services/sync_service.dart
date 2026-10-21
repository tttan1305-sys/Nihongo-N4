import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/flashcard_store.dart';
import '../data/progress_store.dart';
import 'auth_service.dart';

/// Nơi lưu dữ liệu của người dùng trên máy chủ (một tài liệu cho mỗi người).
abstract class CloudStore {
  Future<Map<String, dynamic>?> read(String uid);

  Future<void> write(String uid, Map<String, dynamic> data);
}

/// Lưu ở Firestore, tài liệu `users/<uid>`. Quy tắc bảo mật: `firestore.rules`.
class FirestoreCloudStore implements CloudStore {
  final FirebaseFirestore _db;

  FirestoreCloudStore(this._db);

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid);

  @override
  Future<Map<String, dynamic>?> read(String uid) async =>
      (await _doc(uid).get()).data();

  @override
  Future<void> write(String uid, Map<String, dynamic> data) =>
      _doc(uid).set({...data, 'updatedAt': FieldValue.serverTimestamp()});
}

enum SyncStatus { off, syncing, synced, error }

/// Đồng bộ tiến độ và flashcard: khi đăng nhập thì tải về và gộp với dữ liệu
/// trên máy, sau đó mỗi lần học xong một mục thì đẩy lên (gom lại sau [delay]).
class SyncService extends ChangeNotifier {
  final AuthService auth;
  final ProgressStore progress;
  final FlashcardStore flashcards;
  final CloudStore cloud;
  final Duration delay;

  String? _uid;
  bool _merging = false;
  Timer? _timer;
  SyncStatus _status = SyncStatus.off;
  DateTime? _lastSynced;

  SyncService({
    required this.auth,
    required this.progress,
    required this.flashcards,
    required this.cloud,
    this.delay = const Duration(seconds: 2),
  }) {
    auth.addListener(_onAuth);
    progress.addListener(_onLocalChange);
    flashcards.addListener(_onLocalChange);
    _onAuth();
  }

  SyncStatus get status => _status;

  DateTime? get lastSynced => _lastSynced;

  void _setStatus(SyncStatus s) {
    _status = s;
    if (s == SyncStatus.synced) _lastSynced = DateTime.now();
    notifyListeners();
  }

  void _onAuth() {
    final uid = auth.user?.uid;
    if (uid == _uid) return;
    _uid = uid;
    _timer?.cancel();
    if (uid == null) {
      _setStatus(SyncStatus.off);
    } else {
      unawaited(syncNow());
    }
  }

  void _onLocalChange() {
    if (_uid == null || _merging) return;
    _timer?.cancel();
    _timer = Timer(delay, () => unawaited(_push()));
  }

  /// Tải dữ liệu trên máy chủ, gộp vào máy, rồi đẩy bản đã gộp lên.
  Future<void> syncNow() async {
    final uid = _uid;
    if (uid == null) return;
    _setStatus(SyncStatus.syncing);
    try {
      final remote = await cloud.read(uid);
      if (uid != _uid) return;
      if (remote != null) {
        _merging = true;
        try {
          await progress.mergeData(_map(remote['progress']));
          await flashcards.mergeData(_map(remote['flashcards']));
        } finally {
          _merging = false;
        }
      }
      await _write(uid);
    } catch (e) {
      debugPrint('Đồng bộ lỗi: $e');
      if (uid == _uid) _setStatus(SyncStatus.error);
    }
  }

  Future<void> _push() async {
    final uid = _uid;
    if (uid == null) return;
    _setStatus(SyncStatus.syncing);
    try {
      await _write(uid);
    } catch (e) {
      debugPrint('Đồng bộ lỗi: $e');
      if (uid == _uid) _setStatus(SyncStatus.error);
    }
  }

  Future<void> _write(String uid) async {
    await cloud.write(uid, {
      'progress': progress.exportData(),
      'flashcards': flashcards.exportData(),
    });
    if (uid == _uid) _setStatus(SyncStatus.synced);
  }

  static Map<String, dynamic> _map(Object? raw) =>
      raw is Map ? Map<String, dynamic>.from(raw) : const {};

  @override
  void dispose() {
    _timer?.cancel();
    auth.removeListener(_onAuth);
    progress.removeListener(_onLocalChange);
    flashcards.removeListener(_onLocalChange);
    super.dispose();
  }
}
