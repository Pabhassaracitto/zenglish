import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zenglish/core/providers/locale_provider.dart';
import 'package:zenglish/core/theme/app_theme.dart';
import 'package:zenglish/data/services/user_session_service.dart';
import 'package:zenglish/l10n/app_localizations.dart';
import 'package:zenglish/presentation/widgets/language_selector_sheet.dart';

import '../../../providers/home_provider.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppTheme.spaceMD,
        MediaQuery.of(context).padding.top + AppTheme.spaceMD,
        AppTheme.spaceMD,
        AppTheme.spaceMD,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.divider, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar / logo
          _UserAvatar(isMonk: state.userProfile?.isMonk ?? false),
          const SizedBox(width: AppTheme.spaceMD),

          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.greeting.isEmpty ? 'Chào mừng' : state.greeting,
                  style: AppTheme.headingMedium.copyWith(
                    fontSize: 17,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Vip Buddhism Language',
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Silent mode toggle
          _SilentToggle(
            isSilent: state.silentMode,
            onTap: () => ref.read(homeProvider.notifier).toggleSilentMode(),
          ),

          const SizedBox(width: AppTheme.spaceSM),

          // Globe Button with Tap & Emergency 3s Long Press (Point 3 & 5)
          const _LanguageGlobeAction(),

          const SizedBox(width: AppTheme.spaceSM),

          // Reset Session / Settings (Gear/Refresh)
          _IconAction(
            icon: Icons.settings_outlined,
            onTap: () async {
              await UserSessionService.instance.clearSession();
              if (context.mounted) {
                context.go('/placement');
              }
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _LanguageGlobeAction extends ConsumerWidget {
  const _LanguageGlobeAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: 'Chạm để chọn ngôn ngữ · Nhấn giữ 3 giây để khôi phục về hệ thống\nTap to change language · Long press 3s to restore system default',
      child: GestureDetector(
        onTap: () => LanguageSelectorSheet.show(context),
        onLongPress: () {
          // Emergency restore (Point 5)
          ref.read(localeProvider.notifier).resetToSystem();

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                '✓ Đã khôi phục về Ngôn ngữ hệ thống / Restored to System Default',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppTheme.earthDark,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        },
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.surfaceVariant,
            border: Border.all(color: AppTheme.divider),
          ),
          child: const Center(
            child: Text('🌐', style: TextStyle(fontSize: 18)),
          ),
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.isMonk});
  final bool isMonk;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primary.withOpacity(0.1),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          isMonk ? '🙏' : '🧘',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class _SilentToggle extends StatelessWidget {
  const _SilentToggle({
    required this.isSilent,
    required this.onTap,
  });
  final bool isSilent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceSM,
          vertical: 6,
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
              isSilent ? Icons.volume_off : Icons.volume_up_outlined,
              size: 15,
              color: isSilent ? Colors.white : AppTheme.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              isSilent ? l10n.silentMode : 'Audio',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSilent ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.surfaceVariant,
          border: Border.all(color: AppTheme.divider),
        ),
        child: Icon(icon, size: 18, color: AppTheme.textSecondary),
      ),
    );
  }
}
