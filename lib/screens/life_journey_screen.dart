import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../data/questions.dart';
import '../l10n/translations.dart';
import '../models/parent_profile.dart';
import '../services/storage_service.dart';
import 'question_screen.dart';
import 'generate_book_screen.dart';

class _LifeStageGroup {
  final String titleKey;
  final String descKey;
  final String emoji;
  final int startChapter;
  final int endChapter;

  const _LifeStageGroup({
    required this.titleKey,
    required this.descKey,
    required this.emoji,
    required this.startChapter,
    required this.endChapter,
  });
}

class LifeJourneyScreen extends StatefulWidget {
  final ParentProfile profile;
  const LifeJourneyScreen({super.key, required this.profile});

  @override
  State<LifeJourneyScreen> createState() => _LifeJourneyScreenState();
}

class _LifeJourneyScreenState extends State<LifeJourneyScreen> {
  final _storageService = StorageService();
  Map<String, int> _progress = {};
  final Set<int> _expandedGroups = {0};

  static const _groups = [
    _LifeStageGroup(titleKey: 'groupChildhood', descKey: 'groupChildhoodDesc', emoji: '🌱', startChapter: 0, endChapter: 4),
    _LifeStageGroup(titleKey: 'groupYouth', descKey: 'groupYouthDesc', emoji: '🌿', startChapter: 5, endChapter: 7),
    _LifeStageGroup(titleKey: 'groupFamily', descKey: 'groupFamilyDesc', emoji: '🏡', startChapter: 8, endChapter: 12),
    _LifeStageGroup(titleKey: 'groupJourney', descKey: 'groupJourneyDesc', emoji: '🛤️', startChapter: 13, endChapter: 16),
    _LifeStageGroup(titleKey: 'groupLegacy', descKey: 'groupLegacyDesc', emoji: '🌟', startChapter: 17, endChapter: 19),
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  void _loadProgress() {
    setState(() {
      _progress = _storageService.getCompletionProgress(widget.profile.id);
    });
  }

  int get _totalAnswered => _progress.values.fold(0, (sum, c) => sum + c);

  Widget _buildEmptyStateOrProgress() {
    if (_totalAnswered == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s),
        child: Text(
          T.tr('emptyMemories'),
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(
            color: AppColors.text,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s),
        child: Text(
          T.tr('sharedMemoriesCount').replaceAll('{count}', '$_totalAnswered'),
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(
            color: AppColors.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chapters = QuestionDatabase.chapters;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.profile.name),
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.s),
          _buildEmptyStateOrProgress(),
          const SizedBox(height: AppSpacing.l),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              itemCount: _groups.length,
              itemBuilder: (context, groupIndex) {
                final group = _groups[groupIndex];
                final isExpanded = _expandedGroups.contains(groupIndex);

                // Stage Progress via Dots
                final totalChaptersInGroup = group.endChapter - group.startChapter + 1;
                int fullyCompletedChapters = 0;
                for (int i = group.startChapter; i <= group.endChapter; i++) {
                  if (i >= chapters.length) continue;
                  final ch = chapters[i];
                  final completed = _progress[ch.id] ?? 0;
                  if (completed >= ch.questionCount && ch.questionCount > 0) {
                    fullyCompletedChapters++;
                  }
                }
                final isGroupDone = fullyCompletedChapters == totalChaptersInGroup;

                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.s),
                  decoration: BoxDecoration(
                    color: isGroupDone ? AppColors.primary.withOpacity(0.06) : AppColors.card,
                    borderRadius: BorderRadius.circular(AppRadius.l),
                    border: Border.all(
                      color: isGroupDone ? AppColors.primary.withOpacity(0.3) : AppColors.divider,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedGroups.remove(groupIndex);
                            } else {
                              _expandedGroups.add(groupIndex);
                            }
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.l),
                          child: Row(
                            children: [
                              Text(group.emoji, style: const TextStyle(fontSize: 32)),
                              const SizedBox(width: AppSpacing.m),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      T.tr(group.titleKey),
                                      style: AppTypography.heading,
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      T.tr(group.descKey),
                                      style: AppTypography.caption,
                                    ),
                                    const SizedBox(height: AppSpacing.s),
                                    _buildDotProgress(totalChaptersInGroup, fullyCompletedChapters),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s),
                              Icon(
                                isExpanded ? Icons.expand_less : Icons.expand_more,
                                color: AppColors.textLight,
                                size: AppIcons.l,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isExpanded)
                        ...List.generate(totalChaptersInGroup, (i) {
                          final chapterIndex = group.startChapter + i;
                          if (chapterIndex >= chapters.length) return const SizedBox.shrink();
                          final chapter = chapters[chapterIndex];
                          final completed = _progress[chapter.id] ?? 0;
                          final total = chapter.questionCount;
                          final chapterDone = completed >= total && total > 0;

                          return GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QuestionScreen(
                                    profile: widget.profile,
                                    chapterId: chapter.id,
                                    chapterIndex: chapterIndex,
                                  ),
                                ),
                              );
                              _loadProgress();
                            },
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(AppSpacing.l, 0, AppSpacing.l, AppSpacing.m),
                              padding: const EdgeInsets.all(AppSpacing.m),
                              decoration: BoxDecoration(
                                color: chapterDone
                                    ? AppColors.primary.withOpacity(0.04)
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(AppRadius.m),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: AppTouchTargets.min - 16,
                                    height: AppTouchTargets.min - 16,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: chapterDone
                                          ? AppColors.primary
                                          : AppColors.primary.withOpacity(0.08),
                                    ),
                                    child: Center(
                                      child: chapterDone
                                          ? const Icon(Icons.check, color: Colors.white, size: AppIcons.m)
                                          : Text(
                                              '${chapter.number}',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: completed > 0
                                                    ? AppColors.primary
                                                    : AppColors.textLight,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.m),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          chapter.title,
                                          style: AppTypography.body,
                                        ),
                                        if (completed > 0) ...[
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            '$completed of $total memories shared',
                                            style: AppTypography.caption.copyWith(color: AppColors.primary),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    chapterDone ? Icons.check_circle_outline : Icons.chevron_right,
                                    color: AppColors.textLight,
                                    size: AppIcons.l,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.s, AppSpacing.l, AppSpacing.xl),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GenerateBookScreen(profile: widget.profile),
                ),
              ),
              icon: const Icon(Icons.menu_book_outlined, size: AppIcons.l),
              label: Text(T.tr('generateBook')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotProgress(int total, int completed) {
    return Row(
      children: List.generate(total, (index) {
        final isDone = index < completed;
        return Container(
          margin: const EdgeInsets.only(right: 6),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? AppColors.primary : AppColors.divider,
            border: Border.all(
              color: isDone ? AppColors.primary : AppColors.textLight.withOpacity(0.3),
              width: 1,
            ),
          ),
        );
      }),
    );
  }
}
