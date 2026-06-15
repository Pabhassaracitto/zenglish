import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class RadioOptionCard<T> extends StatelessWidget {
  const RadioOptionCard({
    super.key,
    required this.value,
    required this.groupValue,
    required this.label,
    this.sublabel,
    this.leadingIcon,
    required this.onTap,
  });

  final T value;
  final T? groupValue;
  final String label;
  final String? sublabel;
  final Widget? leadingIcon;
  final void Function(T) onTap;

  bool get isSelected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: AppTheme.spaceSM),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceMD,
          vertical: AppTheme.spaceMD - 2,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.06)
              : AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.divider,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? AppTheme.subtleShadow : null,
        ),
        child: Row(
          children: [
            // Leading icon or radio indicator
            if (leadingIcon != null) ...[
              leadingIcon!,
              const SizedBox(width: AppTheme.spaceSM),
            ],
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTheme.bodyLarge.copyWith(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color:
                          isSelected ? AppTheme.primary : AppTheme.textPrimary,
                    ),
                  ),
                  if (sublabel != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      sublabel!,
                      style: AppTheme.bodyMedium.copyWith(
                        fontSize: 12,
                        color: isSelected
                            ? AppTheme.primary.withOpacity(0.7)
                            : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Radio indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.divider,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
