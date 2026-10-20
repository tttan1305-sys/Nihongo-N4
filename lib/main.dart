import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/flashcard_store.dart';
import 'data/lesson_repository.dart';
import 'data/progress_store.dart';
import 'screens/home_screen.dart';
import 'services/recognizer.dart';
import 'services/speaker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    NihongoApp(
      repository: LessonRepository(),
      progress: ProgressStore(prefs),
      flashcards: FlashcardStore(prefs),
      speaker: DeviceSpeaker(),
      recognizer: DeviceRecognizer(),
    ),
  );
}

class NihongoApp extends StatelessWidget {
  final LessonRepository repository;
  final ProgressStore progress;
  final FlashcardStore flashcards;
  final Speaker speaker;
  final Recognizer recognizer;

  const NihongoApp({
    super.key,
    required this.repository,
    required this.progress,
    required this.flashcards,
    required this.speaker,
    required this.recognizer,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nihongo N4',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFBC002D)),
        useMaterial3: true,
      ),
      home: HomeScreen(
        repository: repository,
        progress: progress,
        flashcards: flashcards,
        speaker: speaker,
        recognizer: recognizer,
      ),
    );
  }
}
