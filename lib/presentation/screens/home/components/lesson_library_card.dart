// lib/presentation/screens/home/components/lesson_library_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../providers/catalog_provider.dart';

/// Lối vào thư viện toàn bộ bài học từ màn hình Home.
///
/// Trước đây Home chỉ có 4 thẻ quick-start hardcode nên các bài khác trong
/// `assets/data/lessons/` không có đường vào từ giao diện.
class LessonLibraryCard extends ConsumerWidget {
  const LessonLibraryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(lessonCatalogProvider);

    final subtitle = catalogAsync.when(
      loading: () => 'Đang tải danh sách bài học…',
      error: (_, __) => 'Không tải được danh sách bài học',
      data: (catalog) =>
          'Toàn bộ ${catalog.total} bài · đã hoàn thành ${catalog.completedCount}',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        onTap: () => context.push(AppRoutes.catalog),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spaceMD),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(color: AppTheme.divider),
            boxShadow: AppTheme.subtleShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                ),
                child: const Icon(
                  Icons.menu_book_outlined,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thư viện bài học',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTheme.labelSmall),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
