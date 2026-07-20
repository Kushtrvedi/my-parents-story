import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../data/questions.dart';
import '../l10n/translations.dart';
import '../models/parent_profile.dart';
import '../models/response.dart';
import '../services/storage_service.dart';
import '../services/native_voice_service.dart';
import '../services/tts_service.dart';
import 'generate_book_screen.dart';

class QuestionScreen extends StatefulWidget {
  final ParentProfile profile;
  final String category;
  final int categoryIndex;

  const QuestionScreen({
    super.key,
    required this.profile,
    required this.category,
    required this.categoryIndex,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final _storageService = StorageService();
  final _voiceService = NativeVoiceService();
  final _ttsService = TextToSpeechService();
  final _textController = TextEditingController();
  late List<String> _questions;
  int _currentQuestionIndex = 0;
  Map<int, StoryResponse> _responses = {};
  bool _isRecording = false;
  String _currentTranscript = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _questions = QuestionDatabase.getQuestionsForCategory(widget.category);
    _loadResponses();
    _voiceService.initialize();
    _ttsService.init();
    _readQuestionAloud();
  }

  @override
  void dispose() {
    _textController.dispose();
    _voiceService.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  void _loadResponses() {
    final responses = _storageService.getResponsesForCategory(
      widget.profile.id,
      widget.category,
    );
    final map = <int, StoryResponse>{};
    for (final r in responses) {
      map[r.questionIndex] = r;
    }
    setState(() => _responses = map);
    _loadCurrentAnswer();
  }

  void _loadCurrentAnswer() {
    final response = _responses[_currentQuestionIndex];
    if (response != null && response.hasAnswer) {
      _textController.text = response.answer;
    } else {
      _textController.clear();
    }
  }

  void _saveAndAutoAdvance() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _storageService.saveResponse(
      profileId: widget.profile.id,
      category: widget.category,
      questionIndex: _currentQuestionIndex,
      question: _questions[_currentQuestionIndex],
      answer: text,
    );

    setState(() {
      _responses[_currentQuestionIndex] = StoryResponse(
        id: '${widget.profile.id}_${widget.category}_$_currentQuestionIndex',
        profileId: widget.profile.id,
        category: widget.category,
        questionIndex: _currentQuestionIndex,
        question: _questions[_currentQuestionIndex],
        answer: text,
      );
      _isSaving = true;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isSaving = false);
    });
  }

  void _nextQuestion() {
    _saveAndAutoAdvance();
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
      _loadCurrentAnswer();
      Future.delayed(const Duration(milliseconds: 300), _readQuestionAloud);
    } else {
      _showChapterComplete();
    }
  }

  void _previousQuestion() {
    _saveAndAutoAdvance();
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
      _loadCurrentAnswer();
      Future.delayed(const Duration(milliseconds: 300), _readQuestionAloud);
    }
  }

  void _readQuestionAloud() {
    _ttsService.speak(_questions[_currentQuestionIndex]);
  }

  void _showChapterComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(T.tr('chapterComplete'), style: Theme.of(context).textTheme.headlineSmall),
        content: Text(T.tr('chapterCompleteBody'), style: Theme.of(context).textTheme.bodyLarge),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _currentQuestionIndex = 0);
              _loadCurrentAnswer();
            },
            child: Text(T.tr('continue_'), style: const TextStyle(fontSize: 20)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => GenerateBookScreen(profile: widget.profile),
                ),
              );
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(160, 56)),
            child: Text(T.tr('generateBook')),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _voiceService.stopListening();
      await _ttsService.stop();
      setState(() {
        _isRecording = false;
        if (_currentTranscript.isNotEmpty) {
          final current = _textController.text;
          _textController.text = current.isEmpty ? _currentTranscript : '$current $_currentTranscript';
          _currentTranscript = '';
        }
      });
    } else {
      if (!_voiceService.isAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(T.tr('voiceUnavailable')), duration: const Duration(seconds: 3)),
          );
        }
        return;
      }
      setState(() {
        _isRecording = true;
        _currentTranscript = '';
      });
      await _voiceService.startListening(onResult: (text) {
        setState(() => _currentTranscript = text);
      });
    }
  }

  double get _progress => (_currentQuestionIndex + 1) / _questions.length;

  @override
  Widget build(BuildContext context) {
    final t = T.tr;
    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                '${_currentQuestionIndex + 1} / ${_questions.length}',
                style: const TextStyle(color: AppColors.secondaryText, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: AppColors.divider,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            minHeight: 4,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Soft category context
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      '${t('todayTalk')} ${widget.category}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.accent),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Question — large, clear
                  Text(
                    currentQuestion,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(height: 1.35),
                  ),
                  const SizedBox(height: 32),
                  // Text input (fallback for typing)
                  TextField(
                    controller: _textController,
                    maxLines: null,
                    minLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: InputDecoration(hintText: t('typeHint')),
                  ),
                  // Live transcript while recording
                  if (_isRecording && _currentTranscript.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.accentLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _currentTranscript,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.primaryText,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ),
                  ],
                  // Auto-save indicator
                  if (_isSaving) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent)),
                        const SizedBox(width: 8),
                        Text(t('saved'), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.success)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Bottom controls — large, simple
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
            ),
            child: Column(
              children: [
                // Voice button — THE primary action
                SizedBox(
                  width: double.infinity,
                  height: 80,
                  child: ElevatedButton.icon(
                    onPressed: _toggleRecording,
                    icon: Icon(
                      _isRecording ? Icons.stop_circle : Icons.mic,
                      size: 36,
                      color: _isRecording ? AppColors.error : Colors.white,
                    ),
                    label: Text(
                      _isRecording ? t('stopRecording') : t('tapToSpeak'),
                      style: TextStyle(
                        fontSize: 26,
                        color: _isRecording ? AppColors.error : Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRecording ? AppColors.error.withValues(alpha: 0.1) : AppColors.accent,
                      foregroundColor: _isRecording ? AppColors.error : Colors.white,
                      side: _isRecording ? const BorderSide(color: AppColors.error, width: 2) : null,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Navigation
                Row(
                  children: [
                    if (_currentQuestionIndex > 0)
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: OutlinedButton(
                            onPressed: _previousQuestion,
                            child: Text(t('previous')),
                          ),
                        ),
                      ),
                    if (_currentQuestionIndex > 0) const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _nextQuestion,
                          child: Text(
                            _currentQuestionIndex == _questions.length - 1
                                ? t('finishChapter')
                                : t('next'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Re-read question button
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _readQuestionAloud,
                  icon: const Icon(Icons.volume_up, size: 22),
                  label: const Text('Read again', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
