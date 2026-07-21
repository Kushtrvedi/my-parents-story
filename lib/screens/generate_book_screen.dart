import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../design_system/design_system.dart';
import '../l10n/translations.dart';
import '../models/parent_profile.dart';
import '../services/storage_service.dart';
import '../services/template_book_service.dart';
import 'book_preview_screen.dart';

class GenerateBookScreen extends StatefulWidget {
  final ParentProfile profile;
  const GenerateBookScreen({super.key, required this.profile});

  @override
  State<GenerateBookScreen> createState() => _GenerateBookScreenState();
}

class _GenerateBookScreenState extends State<GenerateBookScreen> {
  final _storageService = StorageService();
  late final TemplateBookService _templateService = TemplateBookService(_storageService);

  bool _isGenerating = false;
  bool _isDone = false;
  int _progress = 0;

  void _startGeneration() async {
    setState(() {
      _isGenerating = true;
      _progress = 0;
    });

    for (int i = 0; i <= 100; i += 2) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (mounted) setState(() => _progress = i);
    }

    final responses = _storageService.getMemoriesForProfile(widget.profile.id);
    final book = _templateService.generateBook(widget.profile, responses);

    setState(() {
      _isGenerating = false;
      _isDone = true;
    });

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookPreviewScreen(profile: widget.profile, book: book),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(T.tr('generateBook')),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isGenerating) ...[
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.08),
                  ),
                  child: const Icon(
                    Icons.menu_book_outlined,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  T.tr('generatingBook'),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                // Progress bar — gentle
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progress / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '$_progress%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                        fontSize: 18,
                      ),
                ),
              ] else if (_isDone) ...[
                Icon(
                  Icons.check_circle,
                  size: 80,
                  color: AppColors.success,
                ),
                const SizedBox(height: 24),
                Text(
                  T.tr('bookDone'),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ] else ...[
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.08),
                  ),
                  child: const Icon(
                    Icons.auto_stories_outlined,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  T.tr('readyToCreate'),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  '${widget.profile.name}\'s story will become a beautiful PDF book.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textLight,
                      ),
                ),
                const SizedBox(height: 56),
                SizedBox(
                  width: double.infinity,
                  height: 76,
                  child: ElevatedButton(
                    onPressed: _startGeneration,
                    child: Text(T.tr('generateBook')),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
