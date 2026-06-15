import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../providers/lesson_provider.dart';

class SilentModeButton extends ConsumerWidget {
  const SilentModeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSilent = ref.watch(
      lessonProvider.select((s) => s.isSilentMode),
    );
    final notifier = ref.read(lessonProvider.notifier);

    return GestureDetector(
      onTap: () {
        notifier.toggleSilentMode();
        _showSilentModeSnackbar(context, !isSilent);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceSM + 2,
          vertical: AppTheme.spaceXS + 2,
        ),
        decoration: BoxDecoration(
          color: isSilent ? AppTheme.silentModeActive : AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          border: Border.all(
            color: isSilent ? AppTheme.silentModeActive : AppTheme.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSilent ? Icons.volume_off : Icons.volume_up,
              size: 16,
              color: isSilent ? Colors.white : AppTheme.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              isSilent ? 'Im Lặng' : 'Âm Thanh',
              style: AppTheme.labelSmall.copyWith(
                color: isSilent ? Colors.white : AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSilentModeSnackbar(BuildContext context, bool nowSilent) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nowSilent
              ? 'Chế độ im lặng bật. Audio và ghi âm đã tắt.'
              : 'Chế độ im lặng tắt.',
          style: AppTheme.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        ),
        margin: const EdgeInsets.all(AppTheme.spaceMD),
      ),
    );
  }
}
