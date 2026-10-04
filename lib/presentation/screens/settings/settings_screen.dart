import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zenglish/core/providers/locale_provider.dart';
import 'package:zenglish/core/theme/app_theme.dart';
import 'package:zenglish/data/services/user_session_service.dart';
import 'package:zenglish/presentation/providers/home_provider.dart';
import 'package:zenglish/presentation/widgets/language_selector_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final silent = ref.watch(homeProvider.select((s) => s.silentMode));
    final locale = ref.watch(localeProvider);
    final language = appSupportedLanguages.firstWhere(
      (item) => item.locale == locale,
      orElse: () => appSupportedLanguages.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(title: 'Học tập', children: [
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Chế độ im lặng'),
              subtitle: const Text('Không tự động phát âm thanh'),
              value: silent,
              onChanged: (_) => ref.read(homeProvider.notifier).toggleSilentMode(),
            ),
          ]),
          _Section(title: 'Giao diện', children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.language),
              title: const Text('Ngôn ngữ giao diện'),
              subtitle: Text(language.formattedName),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => LanguageSelectorSheet.show(context),
            ),
          ]),
          _Section(title: 'Dữ liệu', children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.restart_alt, color: AppTheme.errorSoft),
              title: const Text('Làm lại bài kiểm tra đầu vào'),
              subtitle: const Text('Xóa hồ sơ và tiến độ trên thiết bị này'),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Xóa tiến độ?'),
                    content: const Text('Thao tác này không thể hoàn tác.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Hủy')),
                      FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Xóa')),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await UserSessionService.instance.clearSession();
                  if (context.mounted) context.go('/placement');
                }
              },
            ),
          ]),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.1)),
            const SizedBox(height: 6),
            Card(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Column(children: children))),
          ],
        ),
      );
}
