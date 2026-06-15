import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
'package:ewmapp/core/theme/app_theme.dart';
import '../../providers/home_provider.dart';
import 'components/home_header.dart';
import 'components/user_profile_card.dart';
import 'components/smart_suggestion_card.dart';
import 'components/ai_interview_quick_start.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: _buildBody(state),
    );
  }

  Widget _buildBody(HomeState state) {
    if (state.isLoading) return _LoadingBody();
    if (state.error != null) return _ErrorBody(error: state.error!);

    return Column(
      children: [
        // Fixed header (không scroll)
        const HomeHeader(),

        // Scrollable content
        Expanded(
          child: RefreshIndicator(
            color: AppTheme.primary,
            backgroundColor: AppTheme.cardBackground,
            onRefresh: () => ref.read(homeProvider.notifier).refresh(),
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppTheme.spaceLG),
                ),

                // Section 1: User Profile Card
                const SliverToBoxAdapter(
                  child: _SectionLabel(
                    label: 'PROFILE CỦA BẠN',
                    icon: Icons.person_outline,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppTheme.spaceSM),
                ),
                const SliverToBoxAdapter(
                  child: UserProfileCard(),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppTheme.spaceLG),
                ),

                // Section 2: Smart Suggestion
                const SliverToBoxAdapter(
                  child: _SectionLabel(
                    label: 'BÀI HỌC ĐỀ XUẤT',
                    icon: Icons.lightbulb_outline,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppTheme.spaceSM),
                ),
                const SliverToBoxAdapter(
                  child: SmartSuggestionCard(),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppTheme.spaceLG),
                ),

                // Section 3: AI Interview Quick Start
                const SliverToBoxAdapter(
                  child: AIInterviewQuickStart(),
                ),

                // Bottom padding
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: AppTheme.spaceXXL +
                        MediaQuery.of(context).padding.bottom,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.label,
    required this.icon,
  });
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMD,
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.textMuted),
          const SizedBox(width: AppTheme.spaceXS),
          Text(
            label,
            style: AppTheme.labelSmall.copyWith(
              letterSpacing: 1.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primary,
            ),
          ),
          SizedBox(height: AppTheme.spaceMD),
          Text(
            'Đang tải...',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 40,
              color: AppTheme.errorSoft,
            ),
            const SizedBox(height: AppTheme.spaceMD),
            const Text('Có lỗi xảy ra', style: AppTheme.headingMedium),
            const SizedBox(height: AppTheme.spaceSM),
            Text(
              error,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
