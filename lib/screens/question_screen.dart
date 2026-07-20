import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../l10n/translations.dart';
import '../models/parent_profile.dart';
import '../models/question.dart';
import '../services/storage_service.dart';
import '../services/native_voice_service.dart';
import '../services/tts_service.dart';

class QuestionScreen extends StatefulWidget {
  final ParentProfile profile;
  final String chapterId;
  final int chapterIndex;
  const QuestionScreen({
    super.key,
    required this.profile,
    required this.chapterId,
    required this.chapterIndex,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> with SingleTickerProviderStateMixin {
  final _storageService = StorageService();
  final _voiceService = NativeVoiceService();
  final _ttsService = TextToSpeechService();

  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  bool _isRecording = false;
  bool _isSaving = false;
  String _recordedText = '';
  bool _hasRecording = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _ttsService.init();
    _loadQuestions();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _loadQuestions() {
    setState(() {
      _questions = _storageService.getQuestionsForChapter(widget.chapterId);
      if (_questions.isEmpty) {
        _questions = [];
      }
      _currentQuestionIndex = 0;
      _recordedText = '';
      _hasRecording = false;
    });
  }

  @override
  void dispose() {
    _voiceService.dispose();
    _ttsService.stop();
    _pulseController.dispose();
    super.dispose();
  }

  Question? get _currentQuestion =>
      _questions.isNotEmpty ? _questions[_currentQuestionIndex] : null;

  void _speakQuestion() {
    final q = _currentQuestion;
    if (q != null) {
      _ttsService.speak(q.question);
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _voiceService.stopListening();
      _pulseController.stop();
      setState(() {
        _isRecording = false;
        _hasRecording = _recordedText.trim().isNotEmpty;
      });
    } else {
      await _voiceService.startListening(
        onResult: (text) {
          if (mounted) setState(() => _recordedText = text);
        },
      );
      _pulseController.repeat(reverse: true);
      setState(() => _isRecording = true);
    }
  }

  void _retryRecording() {
    setState(() {
      _recordedText = '';
      _hasRecording = false;
    });
  }

  void _saveResponse() {
    if (_recordedText.trim().isEmpty) return;
    final q = _currentQuestion;
    if (q == null) return;

    setState(() => _isSaving = true);

    _storageService.saveResponse(
      profileId: widget.profile.id,
      category: widget.chapterId,
      questionIndex: _currentQuestionIndex,
      question: q.question,
      answer: _recordedText.trim(),
    );

    setState(() => _isSaving = false);

    if (_recordedText.trim().length >= 50) {
      _storageService.incrementMilestone(widget.profile.id, 'stories');
    }
    if (_currentQuestionIndex >= 2) {
      _storageService.incrementMilestone(widget.profile.id, 'sessions');
    }

    if (mounted) {
      _showThankYouAndNext();
    }
  }

  void _showThankYouAndNext() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            const Icon(Icons.auto_awesome, size: 40, color: AppColors.accent),
            const SizedBox(height: 20),
            Text(
              T.tr('insight'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _goToNextQuestion();
                },
                child: Text(T.tr('nextQuestion')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToNextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _recordedText = '';
        _hasRecording = false;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chapter = _storageService.getChapterById(widget.chapterId);
    final chapterTitle = chapter?.title ?? '';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(chapterTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentQuestionIndex + 1} / ${_questions.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textLight,
                      fontSize: 18,
                    ),
              ),
            ),
          ),
        ],
      ),
      body: _currentQuestion == null
          ? Center(
              child: Text(
                'No questions available.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  GestureDetector(
                    onTap: _speakQuestion,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.volume_up_rounded, color: AppColors.primary.withValues(alpha: 0.4), size: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _currentQuestion!.question,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w700,
                                    height: 1.25,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(T.tr('tapToHear'), style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 64),
                  if (_isRecording)
                    _buildPulsingMic()
                  else if (_hasRecording)
                    _buildTextPreview()
                  else
                    _buildMicButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: _toggleRecording,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.mic, color: Colors.white, size: 56),
      ),
    );
  }

  Widget _buildPulsingMic() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withValues(alpha: 0.4),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.stop_rounded, color: Colors.white, size: 64),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Text(
          _recordedText.isEmpty ? T.tr('listening') : _recordedText,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: _recordedText.isEmpty ? AppColors.textLight : AppColors.text,
                fontStyle: _recordedText.isEmpty ? FontStyle.italic : FontStyle.normal,
                fontSize: _recordedText.isEmpty ? 22 : 20,
              ),
        ),
        if (_recordedText.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(T.tr('tapStopHint'), style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }

  Widget _buildTextPreview() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    T.tr('done'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.success,
                          fontSize: 16,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _recordedText,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 20),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 68,
                child: OutlinedButton(
                  onPressed: _retryRecording,
                  child: Text(T.tr('tryAgain')),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 68,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveResponse,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(T.tr('saveResponse')),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
