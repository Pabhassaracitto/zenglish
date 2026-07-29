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

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final l10n = context.l10n;

    final filteredLanguages = appSupportedLanguages.where((lang) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return lang.nativeName.toLowerCase().contains(q) ||
          lang.englishName.toLowerCase().contains(q) ||
          lang.code.toLowerCase().contains(q);
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
                  l10n.selectLanguage,
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

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: '${l10n.selectLanguage}...',
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

          // Language List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // System Default Option
                ListTile(
                  leading: const Text('📱', style: TextStyle(fontSize: 22)),
                  title: Text(
                    l10n.systemDefault,
                    style: TextStyle(
                      fontWeight: currentLocale == null ? FontWeight.bold : FontWeight.normal,
                      color: currentLocale == null ? AppColors.earthBrown : AppColors.textPrimary,
                    ),
                  ),
                  trailing: currentLocale == null
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.earthBrown)
                      : null,
                  onTap: () {
                    ref.read(localeProvider.notifier).resetToSystem();
                    Navigator.of(context).pop();
                  },
                ),
                const Divider(height: 1, indent: 20, endIndent: 20),

                // Supported Languages
                ...filteredLanguages.map((lang) {
                  final isSelected = currentLocale != null &&
                      currentLocale.languageCode == lang.code &&
                      (lang.countryCode == null || currentLocale.countryCode == lang.countryCode);

                  return ListTile(
                    leading: Text(lang.flagEmoji, style: const TextStyle(fontSize: 22)),
                    title: Text(
                      lang.nativeName,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.earthBrown : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      lang.englishName,
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary.withOpacity(0.8)),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.earthBrown)
                        : null,
                    onTap: () {
                      ref.read(localeProvider.notifier).setLocale(lang.locale);
                      Navigator.of(context).pop();
                    },
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
