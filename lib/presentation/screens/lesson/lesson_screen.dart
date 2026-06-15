import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zenglishapp/core/theme/app_theme.dart';
import '../../providers/lesson_provider.dart';
import 'components/lesson_progress_bar.dart';
import 'components/lesson_stage_header.dart';
import 'components/silent_mode_button.dart';
import 'stages/guided_stage.dart';
import 'stages/input_stage.dart';
import 'stages/output_stage.dart';
import 'stages/pattern_stage.dart';

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key, required this.lessonId});
  final String lessonId;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  @override
  void initState() {
    super.initState();
    // Load lesson after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lessonProvider.notifier).loadLesson(widget.lessonId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lessonProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: _buildAppBar(state),
      body: _buildBody(state),
    );
  }

  PreferredSizeWidget _buildAppBar(LessonState state) {
    return AppBar(
      backgroundColor: AppTheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 18,
          color: AppTheme.textPrimary,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: state.hasLesson
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.lesson!.level.displayName,
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  state.lesson!.chapter,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : const SizedBox(),
      actions: const [
        SilentModeButton(),
        SizedBox(width: AppTheme.spaceSM),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: state.hasLesson
            ? const LessonProgressBar()
            : const SizedBox(height: 72),
      ),
    );
  }

  Widget _buildBody(LessonState state) {
    if (state.isLoading) return _LoadingView();

    if (state.error != null) {
      return _ErrorView(
        error: state.error!,
        onRetry: () =>
            ref.read(lessonProvider.notifier).loadLesson(widget.lessonId),
      );
    }

    if (!state.hasLesson) return const SizedBox();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            )),
            child: child,
          ),
        );
      },
      child: _buildCurrentStage(state),
    );
  }

  Widget _buildCurrentStage(LessonState state) {
    final lesson = state.lesson!;

    Widget stageWidget;
    switch (state.currentStage) {
      case LessonStage.input:
        stageWidget = const InputStage();
        break;
      case LessonStage.pattern:
        stageWidget = const PatternStage();
        break;
      case LessonStage.guided:
        stageWidget = const GuidedStage();
        break;
      case LessonStage.output:
        stageWidget = const OutputStage();
        break;
    }

    return CustomScrollView(
      key: ValueKey(state.currentStage),
      slivers: [
        SliverToBoxAdapter(
          child: LessonStageHeader(
            stage: state.currentStage,
            titleEn: lesson.titleEn,
            titleVi: lesson.titleVi,
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: true,
          child: stageWidget,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: AppTheme.spaceMD),
          Text(
            'Đang tải bài học...',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 40,
              color: AppTheme.errorSoft,
            ),
            const SizedBox(height: AppTheme.spaceMD),
            Text(
              'Không thể tải bài học',
              style: AppTheme.headingMedium,
            ),
            const SizedBox(height: AppTheme.spaceSM),
            Text(
              error,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceLG),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
