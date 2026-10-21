import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_n4/data/flashcard_store.dart';
import 'package:nihongo_n4/data/progress_store.dart';
import 'package:nihongo_n4/screens/home_screen.dart';
import 'package:nihongo_n4/services/sync_service.dart';
import 'package:nihongo_n4/srs/sm2.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_test.dart' show FakeAuth;

class FakeCloud implements CloudStore {
  final docs = <String, Map<String, dynamic>>{};
  int writes = 0;
  bool fail = false;

  @override
  Future<Map<String, dynamic>?> read(String uid) async {
    if (fail) throw Exception('offline');
    final d = docs[uid];
    // Giả lập dữ liệu đi qua mạng: không dùng chung đối tượng với máy.
    return d == null ? null : jsonDecode(jsonEncode(d)) as Map<String, dynamic>;
  }

  @override
  Future<void> write(String uid, Map<String, dynamic> data) async {
    if (fail) throw Exception('offline');
    writes++;
    docs[uid] = jsonDecode(jsonEncode(data)) as Map<String, dynamic>;
  }
}

Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  late ProgressStore progress;
  late FlashcardStore flashcards;
  late FakeAuth auth;
  late FakeCloud cloud;
  final t0 = DateTime(2026, 10, 21, 9);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    progress = ProgressStore(prefs);
    flashcards = FlashcardStore(prefs, clock: () => t0);
    auth = FakeAuth();
    cloud = FakeCloud();
  });

  SyncService start() => SyncService(
    auth: auth,
    progress: progress,
    flashcards: flashcards,
    cloud: cloud,
    delay: Duration.zero,
  );

  test('chưa đăng nhập thì không đồng bộ', () async {
    final sync = start();
    await progress.saveGrammarScore(26, 'g1', 0.9);
    await settle();
    expect(cloud.writes, 0);
    expect(sync.status, SyncStatus.off);
  });

  test('đăng nhập thì gộp dữ liệu máy chủ với máy rồi đẩy lên', () async {
    await progress.saveGrammarScore(26, 'g1', 0.6);
    await progress.saveGrammarScore(26, 'g2', 1.0);
    await flashcards.add(26, 'v01');
    cloud.docs['u1'] = {
      'progress': {
        'grammar.26.g1': 0.9,
        'grammar.26.g2': 0.5,
        'vocabDone.26': true,
      },
      'flashcards': {'26:v02': CardState.fresh(t0).toJson()},
    };
    final sync = start();
    await auth.signInWithGoogle();
    await settle();
    await settle();

    expect(sync.status, SyncStatus.synced);
    expect(progress.grammarScore(26, 'g1'), 0.9);
    expect(progress.grammarScore(26, 'g2'), 1.0);
    expect(progress.isVocabDone(26), isTrue);
    expect(flashcards.totalCount, 2);
    final up = cloud.docs['u1']!;
    expect(up['progress']['grammar.26.g2'], 1.0);
    expect((up['flashcards'] as Map).keys, containsAll(['26:v01', '26:v02']));
  });

  test('thẻ có ở cả hai nơi thì giữ bản ôn gần đây hơn', () async {
    await flashcards.add(26, 'v01');
    final old = review(CardState.fresh(t0), Rating.again, t0);
    final newer = review(
      CardState.fresh(t0),
      Rating.easy,
      t0.add(const Duration(hours: 1)),
    );
    cloud.docs['u1'] = {
      'flashcards': {'26:v01': newer.toJson()},
    };
    await flashcards.mergeData({'26:v01': old.toJson()});
    expect(flashcards.stateOf(const CardId(26, 'v01'))!.lapses, 1);

    start();
    await auth.signInWithGoogle();
    await settle();
    await settle();
    final s = flashcards.stateOf(const CardId(26, 'v01'))!;
    expect(s.lapses, 0);
    expect(s.intervalDays, newer.intervalDays);
  });

  test('học xong một mục thì đẩy lên máy chủ', () async {
    start();
    await auth.signInWithGoogle();
    await settle();
    await settle();
    final before = cloud.writes;
    await progress.saveReadingScore(26, 1.0);
    await settle();
    await settle();
    expect(cloud.writes, before + 1);
    expect(cloud.docs['u1']!['progress']['reading.26'], 1.0);
  });

  test('cài đặt và chế độ học thử không đồng bộ', () async {
    await progress.setShowFurigana(false);
    await progress.setGuest(true);
    expect(progress.exportData(), isEmpty);
  });

  test('mất mạng thì báo lỗi, bấm đồng bộ lại thì thành công', () async {
    cloud.fail = true;
    final sync = start();
    await auth.signInWithGoogle();
    await settle();
    expect(sync.status, SyncStatus.error);
    expect(syncLabel(sync), contains('thử lại'));

    cloud.fail = false;
    await sync.syncNow();
    expect(sync.status, SyncStatus.synced);
    expect(syncLabel(sync), startsWith('Đã đồng bộ lúc'));
  });

  test('đăng xuất thì ngừng đồng bộ', () async {
    final sync = start();
    await auth.signInWithGoogle();
    await settle();
    await settle();
    await auth.signOut();
    final before = cloud.writes;
    await progress.saveGrammarScore(26, 'g3', 1.0);
    await settle();
    expect(cloud.writes, before);
    expect(sync.status, SyncStatus.off);
  });
}
