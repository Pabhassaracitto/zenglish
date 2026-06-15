import 'package:flutter/material.dart';
import 'package:zenglishapp/core/theme/app_theme.dart';

class PlacementProgressHeader extends StatelessWidget {
  const PlacementProgressHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
  });

  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceMD,
        AppTheme.spaceMD,
        AppTheme.spaceMD,
        AppTheme.spaceLG,
      ),
      child: Column(
        children: [
          // Step indicators
          Row(
            children: List.generate(totalSteps * 2 - 1, (i) {
              // Connector
              if (i.isOdd) {
                final stepBefore = i ~/ 2;
                final isDone = stepBefore < currentStep;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: 2,
                    color: isDone ? AppTheme.primary : AppTheme.divider,
                  ),
                );
              }
              // Step dot
              final step = i ~/ 2;
              final isDone = step < currentStep;
              final isCurrent = step == currentStep;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isCurrent ? 32 : 24,
                height: isCurrent ? 32 : 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? AppTheme.secondary
                      : isCurrent
                          ? AppTheme.primary
                          : AppTheme.surfaceVariant,
                  border: Border.all(
                    color: isCurrent
                        ? AppTheme.primary
                        : isDone
                            ? AppTheme.secondary
                            : AppTheme.divider,
                    width: isCurrent ? 2 : 1,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.25),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(
                          Icons.check,
                          size: 13,
                          color: Colors.white,
                        )
                      : Text(
                          '${step + 1}',
                          style: TextStyle(
                            color:
                                isCurrent ? Colors.white : AppTheme.textMuted,
                            fontSize: isCurrent ? 13 : 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppTheme.spaceSM),
          // Step label
          Text(
            currentStep < stepLabels.length ? stepLabels[currentStep] : '',
            style: AppTheme.labelSmall.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
