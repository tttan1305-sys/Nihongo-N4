// Lặp lại ngắt quãng theo SM-2 (biến thể giống Anki với 4 mức đánh giá).

enum Rating { again, hard, good, easy }

class CardState {
  static const minEase = 1.3;

  final double ease;
  final int intervalDays;
  final int repetitions;
  final int lapses;
  final DateTime due;

  const CardState({
    this.ease = 2.5,
    this.intervalDays = 0,
    this.repetitions = 0,
    this.lapses = 0,
    required this.due,
  });

  factory CardState.fresh(DateTime now) => CardState(due: now);

  factory CardState.fromJson(Map<String, dynamic> j) => CardState(
        ease: (j['ease'] as num).toDouble(),
        intervalDays: j['interval'] as int,
        repetitions: j['reps'] as int,
        lapses: j['lapses'] as int,
        due: DateTime.fromMillisecondsSinceEpoch(j['due'] as int),
      );

  Map<String, dynamic> toJson() => {
        'ease': ease,
        'interval': intervalDays,
        'reps': repetitions,
        'lapses': lapses,
        'due': due.millisecondsSinceEpoch,
      };

  bool get isNew => repetitions == 0 && lapses == 0;

  /// Thẻ cần ôn trong hôm nay (hạn trước 0 giờ ngày mai).
  bool isDue(DateTime now) => due.isBefore(DateTime(now.year, now.month, now.day + 1));
}

/// Thời gian chờ trước khi gặp lại thẻ vừa bấm "Quên".
const relearnDelay = Duration(minutes: 10);

CardState review(CardState s, Rating rating, DateTime now) {
  switch (rating) {
    case Rating.again:
      return CardState(
        ease: _clampEase(s.ease - 0.2),
        intervalDays: 0,
        repetitions: 0,
        lapses: s.lapses + 1,
        due: now.add(relearnDelay),
      );
    case Rating.hard:
      final interval = s.repetitions == 0 ? 1 : _atLeast(s.intervalDays * 1.2, s.intervalDays + 1);
      return _next(s, _clampEase(s.ease - 0.15), interval, now);
    case Rating.good:
      final interval = switch (s.repetitions) {
        0 => 1,
        1 => 3,
        _ => _atLeast(s.intervalDays * s.ease, s.intervalDays + 1),
      };
      return _next(s, s.ease, interval, now);
    case Rating.easy:
      final interval = switch (s.repetitions) {
        0 => 4,
        1 => 7,
        _ => _atLeast(s.intervalDays * s.ease * 1.3, s.intervalDays + 1),
      };
      return _next(s, s.ease + 0.15, interval, now);
  }
}

/// Số ngày đến lần ôn tiếp theo nếu chọn [rating], để ghi trên nút.
String nextIntervalLabel(CardState s, Rating rating, DateTime now) {
  if (rating == Rating.again) return '${relearnDelay.inMinutes} phút';
  final days = review(s, rating, now).intervalDays;
  if (days < 30) return '$days ngày';
  if (days < 365) return '${(days / 30).round()} tháng';
  return '${(days / 365).toStringAsFixed(1)} năm';
}

CardState _next(CardState s, double ease, int interval, DateTime now) => CardState(
      ease: ease,
      intervalDays: interval,
      repetitions: s.repetitions + 1,
      lapses: s.lapses,
      due: now.add(Duration(days: interval)),
    );

double _clampEase(double e) => e < CardState.minEase ? CardState.minEase : e;

int _atLeast(double value, int min) {
  final v = value.round();
  return v < min ? min : v;
}
