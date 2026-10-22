import 'package:flutter/material.dart';

import '../data/flashcard_store.dart';
import '../data/lesson_repository.dart';
import '../data/n5_repository.dart';
import '../data/progress_store.dart';
import '../data/word_bank.dart';
import '../models/n5.dart';
import '../services/auth_service.dart';
import '../services/recognizer.dart';
import '../services/speaker.dart';
import '../services/sync_service.dart';
import '../theme.dart';
import '../widgets/goal_card.dart';
import '../widgets/hero_banner.dart';
import '../widgets/ui.dart';
import 'flashcard_screen.dart';
import 'grammar_list_screen.dart';
import 'lesson_screen.dart';
import 'more_screen.dart';
import 'n5_screen.dart';
import 'practice_screen.dart';
import 'vocab_list_screen.dart';
import 'word_study_screen.dart';

export 'more_screen.dart' show syncLabel;

/// Khung chính của ứng dụng: thanh điều hướng dưới với 4 mục
/// Trang chủ, Từ vựng, Ngữ pháp, Khác.
class HomeScreen extends StatefulWidget {
  final LessonRepository repository;
  final N5Repository n5;
  final ProgressStore progress;
  final FlashcardStore flashcards;
  final Speaker speaker;
  final Recognizer recognizer;
  final AuthService auth;
  final SyncService? sync;

  HomeScreen({
    super.key,
    required this.repository,
    N5Repository? n5,
    required this.progress,
    required this.flashcards,
    required this.speaker,
    required this.recognizer,
    required this.auth,
    this.sync,
  }) : n5 = n5 ?? N5Repository();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  final _visited = <int>{0};
  final _roadmapKey = GlobalKey();
  WordBank? _bank;
  N5Data? _n5;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final n5 = await widget.n5.load();
      final bank = await WordBank.load(widget.repository, widget.n5);
      if (mounted) {
        setState(() {
          _n5 = n5;
          _bank = bank;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadError = e);
    }
  }

  void _select(int tab) => setState(() {
    _tab = tab;
    _visited.add(tab);
  });

  void _showRoadmap() {
    _select(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _roadmapKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 300),
        );
      }
    });
  }

  void _push(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  /// Gọi [build] khi dữ liệu từ vựng, ngữ pháp N5 đã tải xong.
  Widget _withData(Widget Function(WordBank bank, N5Data n5) build) {
    final bank = _bank;
    final n5 = _n5;
    if (bank != null && n5 != null) return build(bank, n5);
    return Scaffold(
      body: Center(
        child: _loadError == null
            ? const CircularProgressIndicator()
            : Text('Không tải được dữ liệu: $_loadError'),
      ),
    );
  }

  void _whenLoaded(void Function(WordBank bank, N5Data n5) action) {
    final bank = _bank;
    final n5 = _n5;
    if (bank != null && n5 != null) {
      action(bank, n5);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đang tải dữ liệu, thử lại sau giây lát.'),
        ),
      );
    }
  }

  void _learnWords() => _whenLoaded((bank, _) {
    final open = unlockedWords(bank, widget.progress);
    var words = open
        .where((w) => !widget.progress.isWordLearned(w.key))
        .take(20)
        .toList();
    // Đã học hết thì ôn lại ngẫu nhiên.
    if (words.isEmpty) words = ([...open]..shuffle()).take(20).toList();
    _push(
      WordStudyScreen(
        words: words,
        progress: widget.progress,
        speaker: widget.speaker,
      ),
    );
  });

  void _practice() => _whenLoaded(
    (bank, n5) => _push(
      PracticeScreen(
        bank: bank,
        n5: widget.n5,
        n5Data: n5,
        progress: widget.progress,
        speaker: widget.speaker,
      ),
    ),
  );

  Widget _page(int i) => switch (i) {
    0 => _homeTab(context),
    1 => _withData(
      (bank, _) => VocabListScreen(
        bank: bank,
        progress: widget.progress,
        speaker: widget.speaker,
      ),
    ),
    2 => _withData(
      (bank, n5) => GrammarListScreen(
        lessons: [
          for (final g in bank.groups)
            if (g.lesson != null) g.lesson!,
        ],
        n5: n5,
        progress: widget.progress,
        speaker: widget.speaker,
      ),
    ),
    _ => MoreScreen(
      auth: widget.auth,
      sync: widget.sync,
      progress: widget.progress,
      flashcards: widget.flashcards,
      bank: _bank,
      n5: _n5,
      onRoadmap: _showRoadmap,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          for (var i = 0; i < 4; i++)
            _visited.contains(i) ? _page(i) : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _select,
        destinations: const [
          NavigationDestination(
            key: ValueKey('nav-home'),
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            key: ValueKey('nav-vocab'),
            icon: Icon(Icons.translate_outlined),
            selectedIcon: Icon(Icons.translate_rounded),
            label: 'Từ vựng',
          ),
          NavigationDestination(
            key: ValueKey('nav-grammar'),
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Ngữ pháp',
          ),
          NavigationDestination(
            key: ValueKey('nav-more'),
            icon: Icon(Icons.more_horiz_rounded),
            selectedIcon: Icon(Icons.more_horiz_rounded),
            label: 'Khác',
          ),
        ],
      ),
    );
  }

  Widget _homeTab(BuildContext context) {
    final auth = widget.auth;
    return SingleChildScrollView(
      key: const ValueKey('home-scroll'),
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HeroScenery(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(child: _HeroTitle()),
                    _HeroButton(
                      key: const ValueKey('settings'),
                      icon: Icons.settings_rounded,
                      onPressed: () => _push(
                        SettingsScreen(
                          auth: auth,
                          progress: widget.progress,
                          sync: widget.sync,
                        ),
                      ),
                    ),
                    if (auth.available)
                      _AccountButton(
                        auth: auth,
                        progress: widget.progress,
                        sync: widget.sync,
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GoalCard(bank: _bank, progress: widget.progress),
                const SizedBox(height: 14),
                _LearnButton(onTap: _learnWords),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _FeatureTile(
                        key: const ValueKey('tile-grammar'),
                        color: AppColors.purple,
                        icon: Icons.menu_book_rounded,
                        title: 'Ngữ pháp',
                        subtitle: 'Giải thích • Ví dụ',
                        onTap: () => _select(2),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _FeatureTile(
                        key: const ValueKey('tile-practice'),
                        color: AppColors.green,
                        icon: Icons.task_alt_rounded,
                        title: 'Luyện tập',
                        subtitle: 'Quiz • Trắc nghiệm',
                        onTap: _practice,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _reviewCard(context),
                const SizedBox(height: 14),
                _n5Card(context),
                Padding(
                  key: _roadmapKey,
                  padding: const EdgeInsets.fromLTRB(4, 22, 4, 10),
                  child: const Text(
                    'Lộ trình N4',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                _lessonList(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _lessonList(BuildContext context) {
    return FutureBuilder<Set<int>>(
      future: widget.repository.availableLessons(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final available = snapshot.data!;
        return ListenableBuilder(
          listenable: widget.progress,
          builder: (context, _) => Column(
            children: [
              for (var n = firstLesson; n <= lastLesson; n++)
                _lessonTile(context, n, available.contains(n)),
            ],
          ),
        );
      },
    );
  }

  Widget _lessonTile(BuildContext context, int number, bool written) {
    final progress = widget.progress;
    final unlocked = progress.isLessonUnlocked(number, first: firstLesson);
    final completed = progress.isLessonCompleted(number);
    final ready = written && unlocked;
    final color = completed
        ? AppColors.green
        : ready
        ? AppColors.primary
        : AppColors.muted;
    return AppCard(
      key: ValueKey('lesson-$number'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: ready
          ? () => _push(
              LessonScreen(
                repository: widget.repository,
                progress: progress,
                flashcards: widget.flashcards,
                speaker: widget.speaker,
                recognizer: widget.recognizer,
                number: number,
              ),
            )
          : null,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bài $number',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: ready ? AppColors.text : AppColors.muted,
                  ),
                ),
                Text(
                  !written
                      ? 'Đang soạn nội dung'
                      : completed
                      ? 'Đã hoàn thành'
                      : unlocked
                      ? 'Sẵn sàng'
                      : 'Hoàn thành bài trước để mở',
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(
            completed
                ? Icons.check_circle_rounded
                : ready
                ? Icons.chevron_right_rounded
                : Icons.lock_outline_rounded,
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _n5Card(BuildContext context) {
    return AppCard(
      key: const ValueKey('open-n5'),
      onTap: () => _push(
        N5Screen(
          repository: widget.n5,
          progress: widget.progress,
          speaker: widget.speaker,
        ),
      ),
      child: const Row(
        children: [
          IconTile(Icons.auto_stories_rounded, color: AppColors.pink),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tổng hợp N5',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                Text(
                  'Kiến thức cần nhớ, các thể, ngữ pháp bài 1–25, từ vựng, 5 đề test',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }

  Widget _reviewCard(BuildContext context) {
    final flashcards = widget.flashcards;
    return ListenableBuilder(
      listenable: flashcards,
      builder: (context, _) {
        final due = flashcards.dueCards().length;
        return AppCard(
          child: Row(
            children: [
              const IconTile(Icons.style_rounded, color: AppColors.orange),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flashcards.totalCount == 0
                          ? 'Chưa có flashcard'
                          : 'Hôm nay cần ôn $due thẻ',
                      key: const ValueKey('due-count'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      flashcards.totalCount == 0
                          ? 'Học xong phần Từ vựng của một bài để thêm thẻ.'
                          : 'Tổng cộng ${flashcards.totalCount} thẻ',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                key: const ValueKey('start-review'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                ),
                onPressed: due == 0
                    ? null
                    : () => _push(
                        FlashcardScreen(
                          repository: widget.repository,
                          flashcards: flashcards,
                          progress: widget.progress,
                          speaker: widget.speaker,
                        ),
                      ),
                child: const Text('Ôn'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroTitle extends StatelessWidget {
  const _HeroTitle();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Text(
          'にほんご',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1B2A5C),
            letterSpacing: 2,
          ),
        ),
        Text(
          'Học tiếng Nhật',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1B2A5C),
          ),
        ),
        SizedBox(height: 6),
        SizedBox(
          width: 200,
          child: Text(
            'Mỗi ngày một chút, tiến bộ mỗi ngày 🌸',
            style: TextStyle(fontSize: 14, color: Color(0xFF3B4A72)),
          ),
        ),
      ],
    );
  }
}

class _HeroButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _HeroButton({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.85),
      ),
      icon: Icon(icon, color: AppColors.text),
    );
  }
}

class _LearnButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LearnButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: const LinearGradient(
          colors: [Color(0xFF4F86FF), AppColors.primaryDark],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x402F6BFF),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const ValueKey('learn-words'),
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.style_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Học từ vựng',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Flashcard • Luyện tập',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureTile({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      color: color.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Ảnh đại diện góc phải: xem tài khoản, đăng nhập hoặc đăng xuất.
class _AccountButton extends StatelessWidget {
  final AuthService auth;
  final ProgressStore progress;
  final SyncService? sync;

  const _AccountButton({required this.auth, required this.progress, this.sync});

  @override
  Widget build(BuildContext context) {
    final user = auth.user;
    return PopupMenuButton<String>(
      key: const ValueKey('account'),
      tooltip: 'Tài khoản',
      icon: user?.photoUrl != null
          ? CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(user!.photoUrl!),
            )
          : const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Icon(Icons.person_rounded, color: AppColors.text),
            ),
      onSelected: (value) {
        if (value == 'sign-out') auth.signOut();
        // Bỏ chế độ học thử để quay lại màn hình đăng nhập.
        if (value == 'sign-in') progress.setGuest(false);
        if (value == 'sync') sync?.syncNow();
      },
      itemBuilder: (_) => [
        if (user != null) ...[
          PopupMenuItem(
            enabled: false,
            child: Text('${user.name ?? ''}\n${user.email ?? ''}'.trim()),
          ),
          if (sync != null)
            PopupMenuItem(
              key: const ValueKey('sync'),
              value: 'sync',
              child: Text(syncLabel(sync!)),
            ),
          const PopupMenuItem(value: 'sign-out', child: Text('Đăng xuất')),
        ] else
          const PopupMenuItem(
            value: 'sign-in',
            child: Text('Đăng nhập bằng Google'),
          ),
      ],
    );
  }
}
