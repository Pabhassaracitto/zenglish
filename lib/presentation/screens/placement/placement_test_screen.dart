import 'package:zenglish/core/theme/app_theme.dart';
import 'package:zenglish/data/models/placement_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenglish/presentation/screens/lesson/lesson_screen.dart';
import '../../providers/placement_provider.dart';
import 'components/placement_progress_header.dart';
import 'components/placement_result_card.dart';
import 'steps/step_meditation.dart';
import 'steps/step_pali.dart';
import 'steps/step_vocab.dart';

class PlacementTestScreen extends ConsumerStatefulWidget {
  const PlacementTestScreen({super.key});

  @override
  ConsumerState<PlacementTestScreen> createState() =>
      _PlacementTestScreenState();
}

class _PlacementTestScreenState extends ConsumerState<PlacementTestScreen>
    with SingleTickerProviderStateMixin {
  late final PageController pageController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  static const stepLabels = [
    'KINH NGHIỆM THIỀN',
    'KIẾN THỨC PĀḶI',
    'KIỂM TRA TỪ VỰNG',
  ];

  @override
  void initState() {
    super.initState();
    pageController = PageController(viewportFraction: 1.0);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void animateToPage(int page) {
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> handleNext() async {
    final state = ref.read(placementProvider);
    final notifier = ref.read(placementProvider.notifier);
    if (!state.canProceedCurrentStep) return;

    // Last step → calculate
    if (state.currentStep == PlacementState.totalSteps - 1) {
      await notifier.calculate();
      return;
    }

    notifier.nextStep();
    animateToPage(state.currentStep + 1);
  }

  void handleBack() {
    final state = ref.read(placementProvider);
    if (state.currentStep == 0) {
      Navigator.of(context).pop();
      return;
    }
    ref.read(placementProvider.notifier).previousStep();
    animateToPage(state.currentStep - 1);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(placementProvider);

    // Show result screen
    if (state.isComplete) {
      return ResultScreen(result: state.result!);
    }

    // Show calculating
    if (state.isCalculating) {
      return const CalculatingScreen();
    }

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: buildAppBar(state),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Progress header
            PlacementProgressHeader(
              currentStep: state.currentStep,
              totalSteps: PlacementState.totalSteps,
              stepLabels: stepLabels,
            ),
            // Page view
            Expanded(
              child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  StepMeditation(),
                  StepPali(),
                  StepVocab(),
                ],
              ),
            ),
            // Bottom navigation
            BottomNavBar(
              state: state,
              onBack: handleBack,
              onNext: handleNext,
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget buildAppBar(PlacementState state) {
    return AppBar(
      backgroundColor: AppTheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 18,
          color: AppTheme.textPrimary,
        ),
        onPressed: handleBack,
      ),
      title: const Text(
        'Đánh Giá Đầu Vào',
        style: AppTheme.headingMedium,
      ),
      centerTitle: false,
      actions: [
        // Skip option
        TextButton(
          onPressed: () {
            // Skip → go to default A1CH01
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const LessonScreen(lessonId: 'A1_CH01_L01'),
              ),
            );
          },
          child: Text(
            'Bỏ qua',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// BOTTOM NAV BAR
// ─────────────────────────────────────────────
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.state,
    required this.onBack,
    required this.onNext,
  });

  final PlacementState state;
  final VoidCallback onBack;
  final Future<void> Function() onNext;

  bool get isLastStep => state.currentStep == PlacementState.totalSteps - 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppTheme.spaceMD,
        AppTheme.spaceSM,
        AppTheme.spaceMD,
        AppTheme.spaceMD + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back button
          if (state.currentStep > 0)
            OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                side: const BorderSide(color: AppTheme.divider),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceMD,
                  vertical: AppTheme.spaceSM + 4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
              ),
              child: const Text('Quay lại'),
            )
          else
            const SizedBox(width: 90),
          const SizedBox(width: AppTheme.spaceSM),
          // Next / Calculate button
          Expanded(
            child: AnimatedOpacity(
              opacity: state.canProceedCurrentStep ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 200),
              child: ElevatedButton(
                onPressed: state.canProceedCurrentStep ? onNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isLastStep ? AppTheme.secondary : AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spaceSM + 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastStep ? 'Xem kết quả' : 'Tiếp theo',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      isLastStep
                          ? Icons.check_circle_outline
                          : Icons.arrow_forward,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CALCULATING SCREEN
// ─────────────────────────────────────────────
class CalculatingScreen extends StatefulWidget {
  const CalculatingScreen({super.key});

  @override
  State<CalculatingScreen> createState() => _CalculatingScreenState();
}

class _CalculatingScreenState extends State<CalculatingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulsing icon
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, child) => Transform.scale(
                scale: 0.9 + _pulse.value * 0.1,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        AppTheme.primary.withOpacity(0.1 + _pulse.value * 0.1),
                  ),
                  child: const Icon(
                    Icons.spa_outlined,
                    size: 36,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceLG),
            const Text(
              'Đang phân tích...',
              style: AppTheme.headingMedium,
            ),
            const SizedBox(height: AppTheme.spaceSM),
            const Text(
              'App đang tính toán tọa độ 3 trục của bạn',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// RESULT SCREEN
// ─────────────────────────────────────────────
class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key, required this.result});
  final PlacementResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Kết Quả Đánh Giá',
          style: AppTheme.headingMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => ref.read(placementProvider.notifier).reset(),
            child: Text(
              'Làm lại',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: PlacementResultCard(
        result: result,
        onStartLesson: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => LessonScreen(
                lessonId: result.recommendedStartLessonId,
              ),
            ),
          );
        },
      ),
    );
  }
}
