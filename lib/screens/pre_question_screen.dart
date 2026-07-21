import 'package:flutter/material.dart';

import '../design_system/design_system.dart';
import '../l10n/translations.dart';
import '../models/parent_profile.dart';
import 'question_screen.dart';

class PreQuestionScreen extends StatelessWidget {
  final ParentProfile profile;
  final String chapterId;
  final int chapterIndex;

  const PreQuestionScreen({
    super.key,
    required this.profile,
    required this.chapterId,
    required this.chapterIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 26, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(Icons.favorite_rounded, color: AppColors.accent, size: AppIcons.xxl),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                T.tr('preQuestionMessage'),
                textAlign: TextAlign.center,
                style: AppTypography.display.copyWith(
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
              const Spacer(),
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
                        builder: (_) => QuestionScreen(
                          profile: profile,
                          chapterId: chapterId,
                          chapterIndex: chapterIndex,
                        ),
                      ),
                    );
                  },
                  child: Text(T.tr('beginStory')),
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
