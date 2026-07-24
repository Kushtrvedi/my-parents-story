import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../l10n/translations.dart';
import '../models/parent_profile.dart';
import '../models/generated_chapter.dart';
import 'book_preview_screen.dart';
import '../design_system/navigation/page_turn_route.dart';

class CelebrationScreen extends StatelessWidget {
  final ParentProfile profile;
  final GeneratedBook book;

  const CelebrationScreen({
    super.key,
    required this.profile,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    final chapterCount = book.chapters.length;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl, vertical: AppSpacing.xl),
          child: AdaptiveCenteredBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.xl),
                // Golden Keepsake Ribbon Seal
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.amberGold.withValues(alpha: 0.2),
                    border: Border.all(color: AppColors.amberGold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.amberGold.withValues(alpha: 0.3),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.amberGold,
                    size: 48,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Celebration Title
                Text(
                  T.tr('celebrationTitle'),
                  textAlign: TextAlign.center,
                  style: AppTypography.display.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  T.tr('celebrationSubtitle'),
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Milestone Keepsake Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.parchment,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.stars_rounded,
                              color: AppColors.amberGold, size: 20),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'FAMILY HEIRLOOM KEEPSAKE',
                              style: AppTypography.caption.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: AppColors.amberGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '“${profile.name}’s life story has been preserved across $chapterCount chapters for generations to come.”',
                        textAlign: TextAlign.center,
                        style: AppTypography.heading.copyWith(
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                          color: AppColors.primary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '🔒 Saved Safely on Your Device',
                          style: AppTypography.caption.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Primary CTA Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        PageTurnRoute(
                          page: BookPreviewScreen(profile: profile, book: book),
                        ),
                      );
                    },
                    child: Text(
                      T.tr('generateMyBook'),
                      style: AppTypography.button
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
