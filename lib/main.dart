import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/screens/lesson/lesson_screen.dart';
import 'data/di/repository_provider.dart';

void main() {
  // MVP: dùng MockDatabase
  RepositoryProvider.useMock = true;

  runApp(const ProviderScope(child: VipBuddhismApp()));
}

class VipBuddhismApp extends StatelessWidget {
  const VipBuddhismApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vip Buddhism Language',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const LessonScreen(lessonId: 'A2_CH06_L01'),
    );
  }
}
