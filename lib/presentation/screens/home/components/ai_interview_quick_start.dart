import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zenglishapp/core/theme/app_theme.dart';
import '../../../providers/home_provider.dart';

/// Quick-start shortcuts cho các tình huống trình pháp thường gặp
class AIInterviewQuickStart extends ConsumerWidget {
  const AIInterviewQuickStart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          _SectionTitle(),
          const SizedBox(height: AppTheme.spaceSM),

          // Main CTA
          _MainCTA(silentMode: state.silentMode),
          const SizedBox(height: AppTheme.spaceSM),

          // Quick cards
          const _QuickCardGrid(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: AppTheme.secondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppTheme.spaceSM),
        const Text(
          'Trình Pháp Nhanh',
          style: AppTheme.headingMedium,
        ),
        const Spacer(),
        Text(
          'AI Interview',
          style: AppTheme.labelSmall.copyWith(
            color: AppTheme.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────

class _MainCTA extends StatelessWidget {
  const _MainCTA({required this.silentMode});
  final bool silentMode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to B1_CH12 — 5-part report
        context.push('/lesson/B1_CH12_L01');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hôm nay bạn muốn\ntrình pháp về gì?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXS),
                  Row(
                    children: [
                      const Icon(
                        Icons.smart_toy_outlined,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'AI thiền sư ảo sẽ hỏi — bạn trả lời',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (silentMode) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.volume_off,
                          color: Colors.white54,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Chế độ im lặng đang bật',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _QuickCardGrid extends StatelessWidget {
  final List<_QuickCard> _cards = const [
    _QuickCard(
      emoji: '🌬️',
      title: 'Ānāpāna',
      subtitle: 'Báo cáo hơi thở',
      lessonId: 'A2_CH06_L01',
      accentColor: AppTheme.secondary,
    ),
    _QuickCard(
      emoji: '✋',
      title: 'Giới',
      subtitle: 'Giữ Năm / Tám Giới',
      lessonId: 'A2_CH07_L01',
      accentColor: AppTheme.accent,
    ),
    _QuickCard(
      emoji: '📋',
      title: '5 Phần',
      subtitle: 'Trình pháp đầy đủ',
      lessonId: 'B1_CH12_L01',
      accentColor: AppTheme.primary,
    ),
    _QuickCard(
      emoji: '🏥',
      title: 'Sức khoẻ',
      subtitle: 'Đau / Mệt / Bệnh',
      lessonId: 'A1_CH05_L01',
      accentColor: AppTheme.paliColor,
    ),
  ];

  const _QuickCardGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppTheme.spaceSM,
      mainAxisSpacing: AppTheme.spaceSM,
      childAspectRatio: 1.6,
      children: _cards.map((card) => _QuickCardTile(card: card)).toList(),
    );
  }
}

class _QuickCard {
  const _QuickCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.lessonId,
    required this.accentColor,
  });
  final String emoji;
  final String title;
  final String subtitle;
  final String lessonId;
  final Color accentColor;
}

class _QuickCardTile extends StatelessWidget {
  const _QuickCardTile({required this.card});
  final _QuickCard card;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/lesson/${card.lessonId}'),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceSM + 2),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(
            color: card.accentColor.withOpacity(0.2),
          ),
          boxShadow: AppTheme.subtleShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  card.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppTheme.textMuted,
                ),
              ],
            ),
            const Spacer(),
            Text(
              card.title,
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            Text(
              card.subtitle,
              style: AppTheme.bodyMedium.copyWith(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
