import 'package:flutter/material.dart';

import '../design_system/design_system.dart';
import '../l10n/translations.dart';
import '../models/parent_profile.dart';
import '../services/speech_setup_service.dart';
import 'question_screen.dart';

class PreQuestionScreen extends StatefulWidget {
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
  State<PreQuestionScreen> createState() => _PreQuestionScreenState();
}

class _PreQuestionScreenState extends State<PreQuestionScreen> {
  final _speechService = SpeechSetupService();
  bool _familyMode = false;

  @override
  void initState() {
    super.initState();
    _familyMode = _speechService.isFamilyMode;
  }

  void _toggleFamilyMode() async {
    setState(() => _familyMode = !_familyMode);
    await _speechService.setFamilyMode(_familyMode);
  }

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
        actions: [
          // Family mode toggle
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.s),
            child: GestureDetector(
              onTap: _toggleFamilyMode,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: _familyMode
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _familyMode ? Icons.people_rounded : Icons.person_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _familyMode ? T.tr('familyMode') : T.tr('personalMode'),
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
              const Icon(Icons.favorite_rounded, color: AppColors.accent, size: AppIcons.xxl),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                _familyMode ? T.tr('familyModeMessage') : T.tr('preQuestionMessage'),
                textAlign: TextAlign.center,
                style: AppTypography.display.copyWith(
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
              if (_familyMode) ...[
                const SizedBox(height: AppSpacing.l),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.m),
                  ),
                  child: Text(
                    T.tr('familyModeHint'),
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
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
                        builder: (_) => QuestionScreen(
                          profile: widget.profile,
                          chapterId: widget.chapterId,
                          chapterIndex: widget.chapterIndex,
                          familyMode: _familyMode,
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
            ],
          ),
        ),
      ),
    );
  }
}
