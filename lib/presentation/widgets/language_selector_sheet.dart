import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zenglish/core/providers/locale_provider.dart';
import 'package:zenglish/core/theme/app_theme.dart';
import 'package:zenglish/l10n/app_localizations.dart';

class LanguageSelectorSheet extends ConsumerStatefulWidget {
  const LanguageSelectorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LanguageSelectorSheet(),
    );
  }

  @override
  ConsumerState<LanguageSelectorSheet> createState() => _LanguageSelectorSheetState();
}

class _LanguageSelectorSheetState extends ConsumerState<LanguageSelectorSheet> {
  String _searchQuery = '';

  void _confirmAndApplyLanguage(BuildContext context, SupportedLanguage? targetLang) {
    final currentLocale = ref.read(localeProvider);
    final targetName = targetLang != null ? targetLang.formattedName : 'Theo ngôn ngữ hệ thống · System Default (SYS)';

    showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppColors.creamLight,
          title: Row(
            children: [
              const Icon(Icons.language_rounded, color: AppColors.earthBrown, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Xác nhận / Confirm',
                  style: GoogleFonts.merriweather(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.earthBrown,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chuyển giao diện sang $targetName?',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Switch interface to $targetName?',
                style: const TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppTheme.divider),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('← Hủy / Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.earthBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('✓ Áp dụng / Apply'),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        // Execute confirmed change (Point 7)
        final targetLocale = targetLang?.locale;
        ref.read(localeProvider.notifier).setLocaleConfirmed(targetLocale);

        // Close sheet
        Navigator.of(context).pop();

        // Post-switch Undo SnackBar (Point 4)
        _showPostSwitchSnackBar(context, targetLang);
      }
    });
  }

  void _showPostSwitchSnackBar(BuildContext context, SupportedLanguage? targetLang) {
    final langName = targetLang != null ? targetLang.formattedName : 'System Default';
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '✓ Language changed to $langName',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        action: SnackBarAction(
          label: '↶ Hoàn tác / Undo',
          textColor: AppTheme.saffronLight,
          onPressed: () {
            ref.read(localeProvider.notifier).undoLocaleChange();
          },
        ),
        backgroundColor: AppTheme.earthDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final l10n = context.l10n;

    final filteredLanguages = appSupportedLanguages.where((lang) {
      return lang.matchesQuery(_searchQuery);
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.creamLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.warmTaupe.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.language_rounded, color: AppColors.earthBrown, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Ngôn ngữ · Language',
                  style: GoogleFonts.merriweather(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.earthBrown,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Search Box (Multi-alias, Point 6)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm / Search (vi, English, မြန်မာ...)...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: AppColors.cream,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const Divider(height: 1),

          // Language List with 3 components (Point 2: No flag emojis)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // System Default Option
                ListTile(
                  leading: const Icon(Icons.phonelink_setup_rounded, color: AppColors.earthBrown),
                  title: const Text(
                    'Theo ngôn ngữ hệ thống · System Default (SYS)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  trailing: currentLocale == null
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.earthBrown)
                      : null,
                  onTap: () => _confirmAndApplyLanguage(context, null),
                ),
                const Divider(height: 1, indent: 20, endIndent: 20),

                // Supported Languages (Formatted as: Native · English (TAG))
                ...filteredLanguages.map((lang) {
                  final isSelected = currentLocale != null &&
                      currentLocale.languageCode == lang.code &&
                      (lang.countryCode == null || currentLocale.countryCode == lang.countryCode);

                  return ListTile(
                    leading: Icon(
                      Icons.translate_rounded,
                      size: 20,
                      color: isSelected ? AppColors.earthBrown : AppColors.textSecondary,
                    ),
                    title: Text(
                      lang.formattedName,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
                        color: isSelected ? AppColors.earthBrown : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.earthBrown)
                        : null,
                    onTap: () => _confirmAndApplyLanguage(context, lang),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
