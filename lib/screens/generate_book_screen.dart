import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../data/questions.dart';
import '../l10n/translations.dart';
import '../models/parent_profile.dart';
import '../models/generated_chapter.dart';
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
  late TemplateBookService _bookService;
  String _currentStep = '';
  double _progress = 0;
  List<GeneratedChapter> _chapters = [];
  String _finalLetter = '';
  bool _isGenerating = true;

  @override
  void initState() {
    super.initState();
    _bookService = TemplateBookService(_storageService);
    _generateBook();
  }

  Future<void> _generateBook() async {
    setState(() {
      _currentStep = T.tr('gathering');
      _progress = 0.1;
    });
    await Future.delayed(const Duration(milliseconds: 500));

    final categories = QuestionDatabase.categories;

    _chapters = [];

    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      setState(() {
        final writing = T.tr('writing');
        _currentStep = '$writing $category';
        _progress = 0.1 + (0.7 * ((i + 1) / categories.length));
      });

      final responses = _storageService.getResponsesForCategory(widget.profile.id, category);
      final validResponses = responses.where((r) => r.hasAnswer).toList();
      if (validResponses.isEmpty) continue;

      final content = _bookService.generateChapter(widget.profile, category, responses);

      final chapter = GeneratedChapter(
        id: '${widget.profile.id}_$category',
        profileId: widget.profile.id,
        category: category,
        chapterNumber: i + 1,
        title: category,
        content: content,
      );

      _storageService.saveChapter(chapter);
      _chapters.add(chapter);
      await Future.delayed(const Duration(milliseconds: 200));
    }

    setState(() {
      _currentStep = T.tr('gathering');
      _progress = 0.85;
    });

    final allResponses = _storageService.getResponsesForProfile(widget.profile.id);
    _finalLetter = _bookService.generateFinalLetter(widget.profile, allResponses);

    setState(() {
      _progress = 0.95;
      _currentStep = T.tr('generating');
    });
    await Future.delayed(const Duration(milliseconds: 600));

    setState(() {
      _progress = 1.0;
      _currentStep = T.tr('ready');
      _isGenerating = false;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookPreviewScreen(
            profile: widget.profile,
            chapters: _chapters,
            finalLetter: _finalLetter,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withValues(alpha: 0.1),
                ),
                child: _isGenerating
                    ? const Padding(
                        padding: EdgeInsets.all(28),
                        child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 4),
                      )
                    : const Icon(Icons.auto_stories_rounded, size: 56, color: AppColors.accent),
              ),
              const SizedBox(height: 44),
              Text(
                _currentStep,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 28),
              if (_isGenerating) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: AppColors.divider,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${(_progress * 100).round()}%',
                  style: const TextStyle(fontSize: 18, color: AppColors.secondaryText),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
