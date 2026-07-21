import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../l10n/translations.dart';
import '../models/parent_profile.dart';
import '../models/question.dart';
import '../models/memory.dart';
import '../services/storage_service.dart';
import '../services/native_voice_service.dart';
import '../services/tts_service.dart';
import 'share_memory_screen.dart';

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

class _QuestionScreenState extends State<QuestionScreen> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final _storageService = StorageService();
  final _voiceService = NativeVoiceService();
  final _ttsService = TextToSpeechService();

  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  bool _isRecording = false;
  bool _isSaving = false;
  String _recordedText = '';
  bool _hasRecording = false;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ttsService.init();
    _loadQuestions();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _glowAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOutSine),
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
    WidgetsBinding.instance.removeObserver(this);
    _voiceService.dispose();
    _ttsService.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_isRecording) {
        _toggleRecording();
      }
    }
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
      _glowController.stop();
      setState(() {
        _isRecording = false;
        _hasRecording = _recordedText.trim().isNotEmpty;
      });
      if (!_hasRecording) {
        // If nothing was recorded, just show the error message.
        _showErrorDialog();
      }
    } else {
      await _voiceService.startListening(
        onResult: (text) {
          if (mounted) setState(() => _recordedText = text);
        },
      );
      _glowController.repeat(reverse: true);
      setState(() {
        _isRecording = true;
        _hasRecording = false;
        _recordedText = '';
      });
    }
  }

  void _retryRecording() {
    setState(() {
      _recordedText = '';
      _hasRecording = false;
    });
  }

  void _saveMemory() {
    if (_recordedText.trim().isEmpty) {
      _showErrorDialog();
      return;
    }
    final q = _currentQuestion;
    if (q == null) return;

    setState(() => _isSaving = true);

    final memory = _storageService.saveMemory(
      profileId: widget.profile.id,
      chapterId: widget.chapterId,
      questionId: q.id,
      originalTranscript: _recordedText.trim(),
    );

    setState(() => _isSaving = false);

    if (_recordedText.trim().length >= 50) {
      _storageService.incrementMilestone(widget.profile.id, 'stories');
    }
    if (_currentQuestionIndex >= 2) {
      _storageService.incrementMilestone(widget.profile.id, 'sessions');
    }

    if (mounted) {
      _showSavedAndNext(memory);
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.l)),
        content: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                T.tr('recordingFailed'),
                textAlign: TextAlign.center,
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.l),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(T.tr('ok')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSavedAndNext(Memory memory) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.l)),
        content: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.m),
              Text(
                T.tr('recordingComplete'),
                textAlign: TextAlign.center,
                style: AppTypography.heading,
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShareMemoryScreen(profile: widget.profile, memory: memory),
                      ),
                    );
                  },
                  icon: const Icon(Icons.ios_share_rounded),
                  label: Text(T.tr('shareThisMoment')),
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              SizedBox(
                width: double.infinity,
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

  Widget _buildProgressIndicator() {
    if (_questions.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_questions.length, (index) {
        final isActive = index == _currentQuestionIndex;
        final isPast = index < _currentQuestionIndex;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive || isPast ? AppColors.primary : AppColors.divider,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chapter = _storageService.getChapterById(widget.chapterId);
    final chapterTitle = chapter?.title ?? '';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _currentQuestion == null
          ? Center(
              child: Text(
                'No questions available.',
                style: AppTypography.body,
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.m),
                child: Column(
                  children: [
                    // Chapter Title
                    Text(
                      chapterTitle,
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(fontSize: 22, color: AppColors.textLight),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    
                    // Question Progress
                    Text(
                      'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                      textAlign: TextAlign.center,
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    _buildProgressIndicator(),
                    const SizedBox(height: AppSpacing.xl),

                    // Question Text
                    Expanded(
                      child: Center(
                        child: GestureDetector(
                          onTap: _speakQuestion,
                          child: Text(
                            _currentQuestion!.question,
                            textAlign: TextAlign.center,
                            style: AppTypography.question,
                          ),
                        ),
                      ),
                    ),

                    // Microphone Area
                    if (_isRecording)
                      _buildRecordingState()
                    else if (_hasRecording)
                      _buildReviewState()
                    else
                      _buildIdleState(),

                    const SizedBox(height: AppSpacing.xl),

                    // Continue Later
                    TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, AppTouchTargets.min),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Continue Later',
                        style: AppTypography.button.copyWith(color: AppColors.textLight),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildIdleState() {
    return Column(
      children: [
        GestureDetector(
          onTap: _toggleRecording,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.mic, color: Colors.white, size: AppIcons.xl),
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        Text(
          T.tr('tapToBeginStory'),
          style: AppTypography.caption,
        ),
      ],
    );
  }

  Widget _buildRecordingState() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _glowAnimation.value,
              child: GestureDetector(
                onTap: _toggleRecording,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 30 * _glowAnimation.value,
                        spreadRadius: 10 * _glowAnimation.value,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.stop_rounded, color: Colors.white, size: AppIcons.xl),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.l),
        Text(
          T.tr('listening'),
          style: AppTypography.body,
        ),
      ],
    );
  }

  Widget _buildReviewState() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _retryRecording,
                child: Text(T.tr('tryAgain')),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveMemory,
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(T.tr('saveResponse')),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
