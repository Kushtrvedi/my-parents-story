import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../l10n/translations.dart';
import '../models/parent_profile.dart';
import '../models/generated_chapter.dart';
import 'book_preview_screen.dart';

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
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Heart icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withValues(alpha: 0.2),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.accent,
                  size: 64,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                T.tr('celebrationTitle'),
                textAlign: TextAlign.center,
                style: AppTypography.display.copyWith(
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                T.tr('celebrationSubtitle'),
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookPreviewScreen(profile: profile, book: book),
                      ),
                    );
                  },
                  child: Text(
                    T.tr('generateMyBook'),
                    style: AppTypography.button.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
