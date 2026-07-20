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
    final t = T.tr;
    final categories = QuestionDatabase.categories;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.profile.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.book_outlined, size: 28),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GenerateBookScreen(profile: widget.profile),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile summary
          Container(
            margin: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.warmWhite,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.2), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withValues(alpha: 0.15),
                  ),
                  child: Center(
                    child: Text(
                      widget.profile.name.isNotEmpty ? widget.profile.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.accent),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.profile.name, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        '$_totalAnswered / ${QuestionDatabase.totalQuestions} ${t('memoriesCaptured')}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Categories list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final completed = _progress[category] ?? 0;
                final total = QuestionDatabase.getQuestionCount(category);
                final progress = total > 0 ? completed / total : 0.0;
                final isDone = progress >= 1.0;

                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuestionScreen(
                          profile: widget.profile,
                          category: category,
                          categoryIndex: index,
                        ),
                      ),
                    );
                    _loadProgress();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDone ? AppColors.accent.withValues(alpha: 0.06) : AppColors.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDone ? AppColors.accent.withValues(alpha: 0.4) : AppColors.divider,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone ? AppColors.accent : AppColors.accent.withValues(alpha: 0.1),
                          ),
                          child: Center(
                            child: isDone
                                ? const Icon(Icons.check, color: Colors.white, size: 26)
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: progress > 0 ? AppColors.accent : AppColors.secondaryText,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(category, style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text('$completed / $total ${t('memories')}', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        if (progress > 0 && !isDone)
                          Text(
                            '${(progress * 100).round()}%',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.accent),
                          ),
                        const SizedBox(width: 8),
                        Icon(isDone ? Icons.check_circle : Icons.chevron_right, color: AppColors.secondaryText, size: 26),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
