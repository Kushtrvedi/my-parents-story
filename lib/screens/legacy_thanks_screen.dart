import 'package:flutter/material.dart';

import '../design_system/design_system.dart';
import '../l10n/translations.dart';
import '../models/parent_profile.dart';
import '../models/generated_chapter.dart';
import 'book_preview_screen.dart';

class LegacyThanksScreen extends StatelessWidget {
  final ParentProfile profile;
  final GeneratedBook book;

  const LegacyThanksScreen({
    super.key,
    required this.profile,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: AdaptiveCenteredBox(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppSpacing.xxl),
                      const Icon(Icons.stars_rounded, color: AppColors.accent, size: 80),
                      const SizedBox(height: AppSpacing.xxl),
                      Text(
                        T.tr('legacyThanks'),
                        textAlign: TextAlign.center,
                        style: AppTypography.display.copyWith(
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookPreviewScreen(profile: profile, book: book),
                              ),
                            );
                          },
                          child: Text(T.tr('bookPreview')),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
