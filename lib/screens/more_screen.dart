import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/flashcard_store.dart';
import '../data/progress_store.dart';
import '../data/word_bank.dart';
import '../models/n5.dart';
import '../services/auth_service.dart';
import '../services/sync_service.dart';
import '../theme.dart';
import '../widgets/goal_card.dart';
import '../widgets/ui.dart';

/// Tab Khác: lời chào, mục tiêu học tập, lộ trình, thống kê, cài đặt, góp ý.
class MoreScreen extends StatelessWidget {
  final AuthService auth;
  final SyncService? sync;
  final ProgressStore progress;
  final FlashcardStore flashcards;
  final WordBank? bank;
  final N5Data? n5;
  final VoidCallback onRoadmap;

  const MoreScreen({
    super.key,
    required this.auth,
    required this.progress,
    required this.flashcards,
    required this.onRoadmap,
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
          listenable: auth,
          builder: (context, _) {
            final user = auth.user;
            final name = user?.name?.trim();
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      _Avatar(user: user),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Xin chào, ${name == null || name.isEmpty ? 'bạn' : name.split(' ').last}',
                              key: const ValueKey('greeting'),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              user?.email ??
                                  'Học tiếng Nhật mỗi ngày một chút 🌸',
                              style: const TextStyle(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'Mục tiêu học tập',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ),
                GoalCard(bank: bank, progress: progress),
                const SizedBox(height: 18),
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      _MenuItem(
                        key: const ValueKey('menu-roadmap'),
                        icon: Icons.route_rounded,
                        color: AppColors.primary,
                        title: 'Lộ trình học',
                        onTap: onRoadmap,
                      ),
                      _MenuItem(
                        key: const ValueKey('menu-stats'),
                        icon: Icons.bar_chart_rounded,
                        color: AppColors.green,
                        title: 'Thống kê',
                        onTap: () => _push(
                          context,
                          StatsScreen(
                            progress: progress,
                            flashcards: flashcards,
                            bank: bank,
                            n5: n5,
                          ),
                        ),
                      ),
                      _MenuItem(
                        key: const ValueKey('menu-settings'),
                        icon: Icons.settings_rounded,
                        color: AppColors.purple,
                        title: 'Cài đặt',
                        onTap: () => _push(
                          context,
                          SettingsScreen(
                            auth: auth,
                            progress: progress,
                            sync: sync,
                          ),
                        ),
                      ),
                      _MenuItem(
                        key: const ValueKey('menu-feedback'),
                        icon: Icons.chat_rounded,
                        color: AppColors.orange,
                        title: 'Góp ý',
                        onTap: () => showDialog<void>(
                          context: context,
                          builder: (_) => const _FeedbackDialog(),
                        ),
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

class _Avatar extends StatelessWidget {
  final AppUser? user;

  const _Avatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final photo = user?.photoUrl;
    final name = user?.name?.trim() ?? '';
    return CircleAvatar(
      radius: 30,
      backgroundColor: AppColors.primarySoft,
      backgroundImage: photo == null ? null : NetworkImage(photo),
      child: photo != null
          ? null
          : name.isEmpty
          ? const Text('🌸', style: TextStyle(fontSize: 26))
          : Text(
              name.characters.first.toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: IconTile(icon, color: color, size: 40),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
    );
  }
}

class _FeedbackDialog extends StatefulWidget {
  const _FeedbackDialog();

  @override
  State<_FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<_FeedbackDialog> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Góp ý'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Viết góp ý của bạn, bấm "Chép" rồi dán gửi cho người phát triển.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _text,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Bạn muốn ứng dụng thêm gì?',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
        FilledButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: _text.text));
            if (!context.mounted) return;
            Navigator.pop(context);
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Đã chép góp ý.')));
          },
          child: const Text('Chép'),
        ),
      ],
    );
  }
}

/// Cài đặt: furigana, tài khoản Google, đồng bộ.
class SettingsScreen extends StatelessWidget {
  final AuthService auth;
  final ProgressStore progress;
  final SyncService? sync;

  const SettingsScreen({
    super.key,
    required this.auth,
    required this.progress,
    this.sync,
  });

  @override
  Widget build(BuildContext context) {
    final listen = Listenable.merge([auth, progress, ?sync]);
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListenableBuilder(
        listenable: listen,
        builder: (context, _) {
          final user = auth.user;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: SwitchListTile(
                  key: const ValueKey('settings-furigana'),
                  title: const Text('Hiện furigana'),
                  subtitle: const Text(
                    'Tắt đi để tự kiểm tra cách đọc chữ Hán',
                  ),
                  value: progress.showFurigana,
                  onChanged: progress.setShowFurigana,
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.account_circle_rounded),
                      title: Text(
                        !auth.available
                            ? 'Đang học không cần tài khoản'
                            : user == null
                            ? 'Chưa đăng nhập'
                            : user.name ?? user.email ?? 'Đã đăng nhập',
                      ),
                      subtitle: user?.email == null ? null : Text(user!.email!),
                    ),
                    if (user != null && sync != null)
                      ListTile(
                        key: const ValueKey('settings-sync'),
                        leading: const Icon(Icons.sync_rounded),
                        title: Text(syncLabel(sync!)),
                        onTap: sync!.syncNow,
                      ),
                    if (auth.available)
                      ListTile(
                        key: const ValueKey('settings-account'),
                        leading: Icon(
                          user == null ? Icons.login_rounded : Icons.logout,
                        ),
                        title: Text(
                          user == null ? 'Đăng nhập bằng Google' : 'Đăng xuất',
                        ),
                        onTap: () {
                          if (user == null) {
                            progress.setGuest(false);
                          } else {
                            auth.signOut();
                          }
                          Navigator.of(context).popUntil((r) => r.isFirst);
                        },
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Dòng trạng thái đồng bộ; bấm vào để đồng bộ lại.
String syncLabel(SyncService sync) {
  final t = sync.lastSynced;
  final time = t == null
      ? ''
      : ' lúc ${t.hour.toString().padLeft(2, '0')}:'
            '${t.minute.toString().padLeft(2, '0')}';
  return switch (sync.status) {
    SyncStatus.syncing => 'Đang đồng bộ...',
    SyncStatus.synced => 'Đã đồng bộ$time',
    SyncStatus.error => 'Đồng bộ lỗi, bấm để thử lại',
    SyncStatus.off => 'Đồng bộ ngay',
  };
}

/// Thống kê việc học.
class StatsScreen extends StatelessWidget {
  final ProgressStore progress;
  final FlashcardStore flashcards;
  final WordBank? bank;
  final N5Data? n5;

  const StatsScreen({
    super.key,
    required this.progress,
    required this.flashcards,
    this.bank,
    this.n5,
  });

  @override
  Widget build(BuildContext context) {
    final words = bank?.all.map((w) => w.key).toList() ?? const <String>[];
    final kanji = n5?.kanji ?? const <N5Kanji>[];
    final tests = n5?.tests ?? const <N5Test>[];
    final grammarLessons = [
      for (final g in bank?.groups ?? const <WordGroup>[])
        if (g.lesson != null) g.lesson!,
    ];
    final grammarTotal = grammarLessons.fold(0, (n, l) => n + l.grammar.length);
    final grammarPassed = grammarLessons.fold(
      0,
      (n, l) => n + progress.passedGrammarCount(l),
    );
    final stats = [
      (
        Icons.translate_rounded,
        AppColors.primary,
        'Từ vựng đã học',
        '${progress.learnedCount(words)}/${words.length}',
      ),
      (
        Icons.brush_rounded,
        AppColors.pink,
        'Kanji đã nhớ',
        '${kanji.where((k) => progress.isKanjiLearned(k.char)).length}/${kanji.length}',
      ),
      (
        Icons.menu_book_rounded,
        AppColors.purple,
        'Mẫu ngữ pháp N4 đã qua',
        '$grammarPassed/$grammarTotal',
      ),
      (
        Icons.style_rounded,
        AppColors.orange,
        'Flashcard',
        '${flashcards.totalCount} thẻ · cần ôn ${flashcards.dueCards().length}',
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final (icon, color, label, value) in stats)
            AppCard(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  IconTile(icon, color: color),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: color,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          if (tests.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
              child: Text(
                'Đề test N5 (điểm cao nhất)',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
            AppCard(
              child: Column(
                children: [
                  for (final t in tests)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(child: Text(t.titleVi)),
                          Text(
                            switch (progress.n5TestScore(t.id)) {
                              null => 'Chưa làm',
                              final s => '${(s * 100).round()}%',
                            },
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
