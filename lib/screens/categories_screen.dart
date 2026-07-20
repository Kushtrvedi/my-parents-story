import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../data/questions.dart';
import '../l10n/translations.dart';
import '../models/parent_profile.dart';
import '../services/storage_service.dart';
import 'question_screen.dart';
import 'generate_book_screen.dart';

class CategoriesScreen extends StatefulWidget {
  final ParentProfile profile;
  const CategoriesScreen({super.key, required this.profile});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _storageService = StorageService();
  Map<String, int> _progress = {};

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
              '${T.tr('youreDoingGreat')}  $_totalAnswered ${T.tr('memoriesCaptured')}.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                final completed = _progress[chapter.id] ?? 0;
                final total = chapter.questionCount;
                final progress = total > 0 ? completed / total : 0.0;
                final isDone = progress >= 1.0;

                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuestionScreen(
                          profile: widget.profile,
                          chapterId: chapter.id,
                          chapterIndex: index,
                        ),
                      ),
                    );
                    _loadProgress();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: isDone ? AppColors.primary.withValues(alpha: 0.06) : AppColors.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDone ? AppColors.primary.withValues(alpha: 0.3) : AppColors.divider,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone ? AppColors.primary : AppColors.primary.withValues(alpha: 0.08),
                          ),
                          child: Center(
                            child: isDone
                                ? const Icon(Icons.check, color: Colors.white, size: 24)
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: progress > 0 ? AppColors.primary : AppColors.textLight,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(chapter.title, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(
                                '$completed / $total ${T.tr('memories')}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isDone ? Icons.check_circle_outline : Icons.chevron_right,
                          color: AppColors.textLight,
                          size: 24,
                        ),
                      ],
                    ),
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
