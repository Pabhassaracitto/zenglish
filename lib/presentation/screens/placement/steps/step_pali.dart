import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/placement_result.dart';
import 'package:zenglish/core/theme/app_theme.dart';
import '../../../providers/placement_provider.dart';
import '../components/radio_option_card.dart';
import 'shared_step_widgets.dart';

class StepPali extends ConsumerWidget {
  const StepPali({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      placementProvider.select((s) => s.selectedPali),
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
          const StepHeader(
            stepNumber: 2,
            question: 'Bạn quen thuộc với\nthuật ngữ Pāḷi đến mức nào?',
            subtitle: 'Pāḷi là ngôn ngữ kinh điển Phật giáo Theravāda.',
          ),
          const SizedBox(height: AppTheme.spaceLG),
          // Pali example panel
          const PaliExamplePanel(),
          const SizedBox(height: AppTheme.spaceLG),
          // Options
          ...PaliKnowledgeTier.values.map(
            (tier) => RadioOptionCard<PaliKnowledgeTier>(
              value: tier,
              groupValue: selected,
              label: tier.displayLabel,
              sublabel: tier.sublabel,
              leadingIcon: PaliTierBadge(tier: tier),
              onTap: notifier.selectPali,
            ),
          ),
          const SizedBox(height: AppTheme.spaceLG),
          const PlacementNote(
            note: 'Không cần biết Pāḷi để dùng app. '
                'App luôn có cả 3 ngôn ngữ: '
                'tiếng Anh, tiếng Việt và Pāḷi.',
          ),
        ],
      ),
    );
  }
}

class PaliExamplePanel extends StatelessWidget {
  const PaliExamplePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.paliColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: AppTheme.paliColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ví dụ thuật ngữ Pāḷi thường gặp:',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.paliColor,
            ),
          ),
          const SizedBox(height: AppTheme.spaceSM),
          ...[
            ('ānāpāna', 'aa-naa-paa-na', 'Hơi thở vào-ra'),
            ('nimitta', 'ni-mit-ta', 'Tướng thiền'),
            ('samādhi', 'sa-maa-di', 'Định tâm'),
            ('vipassanā', 'vi-pas-sa-naa', 'Thiền minh sát'),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      item.$1,
                      style: AppTheme.paliText.copyWith(fontSize: 14),
                    ),
                  ),
                  Text(
                    '[${item.$2}]',
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.paliColor.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceSM),
                  const Text('—', style: AppTheme.bodyMedium),
                  const SizedBox(width: 4),
                  Text(item.$3, style: AppTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaliTierBadge extends StatelessWidget {
  const PaliTierBadge({super.key, required this.tier});
  final PaliKnowledgeTier tier;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (tier) {
      PaliKnowledgeTier.none => ('0', AppTheme.textMuted),
      PaliKnowledgeTier.phonetic => ('~', AppTheme.secondary),
      PaliKnowledgeTier.semantic => ('✓', AppTheme.paliColor),
    };

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
