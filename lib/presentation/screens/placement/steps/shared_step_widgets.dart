import 'package:flutter/material.dart';
import 'package:zenglish/core/theme/app_theme.dart';

class StepHeader extends StatelessWidget {
  const StepHeader({
    super.key,
    required this.stepNumber,
    required this.question,
    required this.subtitle,
  });

  final int stepNumber;
  final String question;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: AppTheme.headingLarge,
        ),
        const SizedBox(height: AppTheme.spaceSM),
        Text(subtitle, style: AppTheme.bodyMedium),
      ],
    );
  }
}

class PlacementNote extends StatelessWidget {
  const PlacementNote({super.key, required this.note});
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 16,
            color: AppTheme.textMuted,
          ),
          const SizedBox(width: AppTheme.spaceSM),
          Expanded(
            child: Text(note, style: AppTheme.monasteryNote),
          ),
        ],
      ),
    );
  }
}
