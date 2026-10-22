import 'package:flutter/material.dart';

import '../data/flashcard_store.dart';
import '../data/lesson_repository.dart';
import '../data/progress_store.dart';
import '../data/word_bank.dart';
import '../models/n5.dart';
import '../services/auth_service.dart';
import '../services/sync_service.dart';
import '../theme.dart';
import '../widgets/ui.dart';
import 'more_screen.dart';

/// Số điểm kinh nghiệm cho mỗi cấp.
const xpPerLevel = 500;

/// Điểm kinh nghiệm: 10 cho mỗi từ đã học và mỗi chữ Hán đã nhớ, 30 cho mỗi
/// mẫu ngữ pháp N4 đã qua, 2 cho mỗi câu trả lời đúng.
int studyXp(ProgressStore progress, WordBank? bank, N5Data? n5) {
  final words = progress.learnedCount(bank?.all.map((w) => w.key) ?? const []);
  final kanji = (n5?.kanji ?? const <N5Kanji>[])
      .where((k) => progress.isKanjiLearned(k.char))
      .length;
  final grammar = [
    for (final g in bank?.groups ?? const <WordGroup>[])
      if (g.lesson != null) progress.passedGrammarCount(g.lesson!),
  ].fold(0, (a, b) => a + b);
  return words * 10 + kanji * 10 + grammar * 30 + progress.correctCount * 2;
}

/// Tab Thống kê: hồ sơ, cấp độ, số liệu học tập và thành tích.
class ProfileScreen extends StatelessWidget {
  final AuthService auth;
  final SyncService? sync;
  final ProgressStore progress;
  final FlashcardStore flashcards;
  final WordBank? bank;
  final N5Data? n5;

  const ProfileScreen({
    super.key,
    required this.auth,
    required this.progress,
    required this.flashcards,
    this.sync,
    this.bank,
    this.n5,
  });

  void _push(BuildContext context, Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([auth, progress]),
          builder: (context, _) {
            final user = auth.user;
            final name = user?.name?.trim();
            final words = bank?.all.map((w) => w.key).toList() ?? const [];
            final learned = progress.learnedCount(words);
            final xp = studyXp(progress, bank, n5);
            final accuracy = progress.accuracy;
            final hours = progress.studyTime.inMinutes / 60;
            final streak = progress.streak();
            final kanjiDone = (n5?.kanji ?? const <N5Kanji>[])
                .where((k) => progress.isKanjiLearned(k.char))
                .length;
            final lessonDone = [
              for (var n = firstLesson; n <= lastLesson; n++)
                progress.isLessonCompleted(n),
            ].where((d) => d).length;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primarySoft,
                      backgroundImage: user?.photoUrl == null
                          ? null
                          : NetworkImage(user!.photoUrl!),
                      child: user?.photoUrl == null
                          ? const Icon(
                              Icons.person_rounded,
                              size: 34,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name == null || name.isEmpty
                                ? 'Bạn học'
                                : name.split(' ').last,
                            key: const ValueKey('profile-name'),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Pill('JLPT N4'),
                        ],
                      ),
                    ),
                    IconButton(
                      key: const ValueKey('profile-settings'),
                      tooltip: 'Cài đặt',
                      onPressed: () => _push(
                        context,
                        SettingsScreen(
                          auth: auth,
                          progress: progress,
                          sync: sync,
                        ),
                      ),
                      icon: const Icon(Icons.settings_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _LevelCard(xp: xp),
                const SizedBox(height: 20),
                const _Heading('Thống kê học tập'),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.55,
                  children: [
                    _StatTile(
                      key: const ValueKey('stat-words'),
                      icon: Icons.menu_book_rounded,
                      color: AppColors.primary,
                      value: '$learned',
                      label: 'Từ vựng đã học',
                    ),
                    _StatTile(
                      key: const ValueKey('stat-accuracy'),
                      icon: Icons.check_circle_rounded,
                      color: AppColors.green,
                      value: accuracy == null
                          ? '–'
                          : '${(accuracy * 100).round()}%',
                      label: 'Đúng',
                    ),
                    _StatTile(
                      key: const ValueKey('stat-time'),
                      icon: Icons.schedule_rounded,
                      color: AppColors.purple,
                      value: hours < 10
                          ? hours.toStringAsFixed(1)
                          : '${hours.round()}',
                      unit: 'giờ',
                      label: 'Thời gian học',
                    ),
                    _StatTile(
                      key: const ValueKey('stat-streak'),
                      icon: Icons.local_fire_department_rounded,
                      color: AppColors.orange,
                      value: '$streak',
                      unit: 'ngày',
                      label: 'Chuỗi ngày',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const _Heading('Thành tích'),
                Row(
                  children: [
                    Expanded(
                      child: _Badge(
                        key: const ValueKey('badge-streak'),
                        emoji: '🔥',
                        title: 'Học liên tục 5 ngày',
                        color: AppColors.orange,
                        achieved: streak >= 5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Badge(
                        key: const ValueKey('badge-lesson'),
                        emoji: '🎓',
                        title: 'Hoàn thành 1 bài',
                        color: AppColors.green,
                        achieved: lessonDone >= 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Badge(
                        key: const ValueKey('badge-words'),
                        emoji: '🏆',
                        title: 'Nhớ 100 từ',
                        color: AppColors.purple,
                        achieved: learned >= 100,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AppCard(
                  key: const ValueKey('profile-details'),
                  onTap: () => _push(
                    context,
                    StatsScreen(
                      progress: progress,
                      flashcards: flashcards,
                      bank: bank,
                      n5: n5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const IconTile(
                        Icons.insights_rounded,
                        color: AppColors.pink,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Xem chi tiết',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Kanji đã nhớ $kanjiDone · ngữ pháp, flashcard, đề test N5',
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.muted,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;

  const _Heading(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int xp;

  const _LevelCard({required this.xp});

  @override
  Widget build(BuildContext context) {
    final level = xp ~/ xpPerLevel + 1;
    final inLevel = xp % xpPerLevel;
    return Container(
      key: const ValueKey('level-card'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B2A7A), Color(0xFF16235A)],
        ),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.3),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.purple, AppColors.primary],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple.withValues(alpha: 0.6),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Text(
              'Lv.$level',
              key: const ValueKey('level'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cấp $level',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 8),
                RoundedProgress(
                  value: inLevel / xpPerLevel,
                  color: AppColors.purple,
                  height: 10,
                ),
                const SizedBox(height: 6),
                Text(
                  '$inLevel / $xpPerLevel XP',
                  key: const ValueKey('xp'),
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String unit;
  final String label;

  const _StatTile({
    super.key,
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    this.unit = '',
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderColor: color,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: TextStyle(fontSize: 14, color: color),
                  ),
              ],
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String emoji;
  final String title;
  final Color color;
  final bool achieved;

  const _Badge({
    super.key,
    required this.emoji,
    required this.title,
    required this.color,
    required this.achieved,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: achieved ? 1 : 0.45,
      child: AppCard(
        borderColor: achieved ? color : null,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.18),
                border: Border.all(color: color.withValues(alpha: 0.7)),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, height: 1.25),
            ),
            if (achieved)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.verified_rounded,
                  size: 16,
                  color: AppColors.green,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
