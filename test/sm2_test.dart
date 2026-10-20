import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_n4/srs/sm2.dart';

void main() {
  final now = DateTime(2026, 10, 20, 9);

  test('thẻ mới: Được → 1 ngày, rồi 3 ngày, rồi nhân hệ số dễ', () {
    var s = CardState.fresh(now);
    expect(s.isDue(now), isTrue);
    s = review(s, Rating.good, now);
    expect(s.intervalDays, 1);
    expect(s.due, now.add(const Duration(days: 1)));
    s = review(s, Rating.good, now);
    expect(s.intervalDays, 3);
    s = review(s, Rating.good, now);
    expect(s.intervalDays, 8); // 3 × 2.5 = 7.5 → 8
    expect(s.ease, 2.5);
    expect(s.repetitions, 3);
  });

  test('Quên: về lại từ đầu, giảm hệ số, gặp lại sau 10 phút', () {
    var s = review(
      review(CardState.fresh(now), Rating.good, now),
      Rating.good,
      now,
    );
    s = review(s, Rating.again, now);
    expect(s.repetitions, 0);
    expect(s.lapses, 1);
    expect(s.intervalDays, 0);
    expect(s.ease, closeTo(2.3, 1e-9));
    expect(s.due, now.add(relearnDelay));
    expect(s.isDue(now), isTrue);
  });

  test('hệ số dễ không xuống dưới 1.3', () {
    var s = CardState.fresh(now);
    for (var i = 0; i < 20; i++) {
      s = review(s, Rating.again, now);
    }
    expect(s.ease, CardState.minEase);
  });

  test('Khó và Dễ', () {
    final s = review(CardState.fresh(now), Rating.good, now); // 1 ngày
    final hard = review(s, Rating.hard, now);
    expect(hard.intervalDays, 2);
    expect(hard.ease, closeTo(2.35, 1e-9));
    final easy = review(CardState.fresh(now), Rating.easy, now);
    expect(easy.intervalDays, 4);
    expect(easy.ease, closeTo(2.65, 1e-9));
  });

  test('thẻ hạn ngày mai chưa cần ôn hôm nay; lưu và đọc lại giữ nguyên', () {
    final s = review(CardState.fresh(now), Rating.good, now);
    expect(s.isDue(now), isFalse);
    expect(s.isDue(now.add(const Duration(days: 1))), isTrue);
    final copy = CardState.fromJson(s.toJson());
    expect(copy.toJson(), s.toJson());
  });

  test('nhãn thời gian trên nút', () {
    final s = CardState.fresh(now);
    expect(nextIntervalLabel(s, Rating.again, now), '10 phút');
    expect(nextIntervalLabel(s, Rating.good, now), '1 ngày');
    expect(
      nextIntervalLabel(
        CardState(intervalDays: 40, repetitions: 5, due: now),
        Rating.good,
        now,
      ),
      '3 tháng',
    );
  });
}
