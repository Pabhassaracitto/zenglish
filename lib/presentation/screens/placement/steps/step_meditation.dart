import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/placement_result.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../providers/placement_provider.dart';
import '../components/radio_option_card.dart';
import 'shared_step_widgets.dart';

class StepMeditation extends ConsumerWidget {
  const StepMeditation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      placementProvider.select((s) => s.selectedMeditation),
    );
    final notifier = ref.read(placementProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceMD,
        0,
        AppTheme.spaceMD,
        AppTheme.spaceXXL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          const StepHeader(
            stepNumber: 1,
            question: 'Bạn đang ở đâu\ntrên con đường tu tập?',
            subtitle: 'Chọn mô tả gần nhất với tình trạng hiện tại của bạn.',
          ),
          const SizedBox(height: AppTheme.spaceLG),
          // Options
          ...MeditationExperience.values.map(
            (exp) => RadioOptionCard<MeditationExperience>(
              value: exp,
              groupValue: selected,
              label: exp.displayLabel,
              sublabel: exp.sublabel,
              leadingIcon: MeditationIcon(exp: exp),
              onTap: notifier.selectMeditation,
            ),
          ),
          const SizedBox(height: AppTheme.spaceLG),
          // Monastery note
          const PlacementNote(
            note: 'Bài kiểm tra này không phán xét — '
                'chỉ để app gợi ý đúng bài bắt đầu. '
                'Bạn có thể thay đổi sau.',
          ),
        ],
      ),
    );
  }
}

class MeditationIcon extends StatelessWidget {
  const MeditationIcon({super.key, required this.exp});
  final MeditationExperience exp;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (exp) {
      MeditationExperience.curious => (Icons.search, AppTheme.textMuted),
      MeditationExperience.beginner => (Icons.filter_1, AppTheme.textSecondary),
      MeditationExperience.samathaActive => (
          Icons.self_improvement,
          AppTheme.secondary
        ),
      MeditationExperience.samathaAdvanced => (
          Icons.light_mode,
          AppTheme.accent
        ),
      MeditationExperience.vipassanaActive => (
          Icons.visibility,
          AppTheme.primary
        ),
      MeditationExperience.longTermPractitioner => (
          Icons.spa,
          AppTheme.paliColor
        ),
    };

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}
