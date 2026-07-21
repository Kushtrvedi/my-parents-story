import 'package:flutter/material.dart';
import '../config/app_theme.dart';
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

class CategoriesScreen extends StatefulWidget {
  final ParentProfile profile;
  const CategoriesScreen({super.key, required this.profile});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
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
  int get _totalQuestions => QuestionDatabase.questions.length;

  double _groupProgress(_LifeStageGroup group) {
    int completed = 0;
    int total = 0;
    for (var ch in QuestionDatabase.chapters) {
      if (ch.number - 1 >= group.startChapter && ch.number - 1 <= group.endChapter) {
        completed += _progress[ch.id] ?? 0;
        total += ch.questionCount;
      }
    }
    return total > 0 ? completed / total : 0.0;
  }

  int _groupCompletedCount(_LifeStageGroup group) {
    int completed = 0;
    for (var ch in QuestionDatabase.chapters) {
      if (ch.number - 1 >= group.startChapter && ch.number - 1 <= group.endChapter) {
        completed += _progress[ch.id] ?? 0;
      }
    }
    return completed;
  }

  int _groupTotalCount(_LifeStageGroup group) {
    int total = 0;
    for (var ch in QuestionDatabase.chapters) {
      if (ch.number - 1 >= group.startChapter && ch.number - 1 <= group.endChapter) {
        total += ch.questionCount;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final chapters = QuestionDatabase.chapters;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.profile.name),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Text(
              '${T.tr('youreDoingGreat')}  $_totalAnswered / $_totalQuestions ${T.tr('memoriesCaptured')}.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              itemCount: _groups.length,
              itemBuilder: (context, groupIndex) {
                final group = _groups[groupIndex];
                final isExpanded = _expandedGroups.contains(groupIndex);
                final progress = _groupProgress(group);
                final completedCount = _groupCompletedCount(group);
                final totalCount = _groupTotalCount(group);
                final isDone = progress >= 1.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: isDone ? AppColors.primary.withValues(alpha: 0.06) : AppColors.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDone ? AppColors.primary.withValues(alpha: 0.3) : AppColors.divider,
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
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Text(group.emoji, style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      T.tr(group.titleKey),
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      T.tr(group.descKey),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: progress,
                                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                isDone ? AppColors.primary : AppColors.accent,
                                              ),
                                              minHeight: 6,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '$completedCount / $totalCount',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isExpanded ? Icons.expand_less : Icons.expand_more,
                                color: AppColors.textLight,
                                size: 26,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isExpanded)
                        ...List.generate(group.endChapter - group.startChapter + 1, (i) {
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
                              margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: chapterDone
                                    ? AppColors.primary.withValues(alpha: 0.04)
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: chapterDone
                                          ? AppColors.primary
                                          : AppColors.primary.withValues(alpha: 0.08),
                                    ),
                                    child: Center(
                                      child: chapterDone
                                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                                          : Text(
                                              '${chapter.number}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: completed > 0
                                                    ? AppColors.primary
                                                    : AppColors.textLight,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          chapter.title,
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '$completed / $total ${T.tr('memories')}',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    chapterDone ? Icons.check_circle_outline : Icons.chevron_right,
                                    color: AppColors.textLight,
                                    size: 22,
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
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
            child: SizedBox(
              width: double.infinity,
              height: 68,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GenerateBookScreen(profile: widget.profile),
                  ),
                ),
                icon: const Icon(Icons.menu_book_outlined, size: 24),
                label: Text(T.tr('generateBook')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
