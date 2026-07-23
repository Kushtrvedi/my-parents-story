import 'dart:async';
import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../l10n/translations.dart';
import '../l10n/question_l10n.dart';
import '../models/parent_profile.dart';
import '../models/question.dart';
import '../services/storage_service.dart';
import '../services/native_voice_service.dart';
import '../services/tts_service.dart';
import '../main.dart';
import 'celebration_screen.dart';
import '../design_system/navigation/page_turn_route.dart';
import '../services/template_book_service.dart';

class QuestionScreen extends StatefulWidget {
  final ParentProfile profile;
  final String chapterId;
  final int chapterIndex;
  final bool familyMode;

  const QuestionScreen({
    super.key,
    required this.profile,
    required this.chapterId,
    required this.chapterIndex,
    this.familyMode = false,
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
  late TextEditingController _textController;
  bool _hasRecording = false;
  String _saveStatus = '';
  Timer? _debounce;
  bool _showImproveStory = false;
  bool _showMemoryPause = false;
  bool _showBreakReminder = false;
  int _questionsAnswered = 0;
  DateTime? _sessionStartTime;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  static const int _breakReminderMinutes = 15;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    WidgetsBinding.instance.addObserver(this);
    _ttsService.init();
    _sessionStartTime = DateTime.now();
    _loadQuestions();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _glowAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOutSine),
    );
    // Auto-read question after delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _speakQuestion();
    });
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
    _textController.dispose();
    _debounce?.cancel();
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

  void _speakQuestion() async {
    final q = _currentQuestion;
    if (q != null) {
      final langCode = localeProvider.locale.languageCode;
      final textToSpeak = q.getLocalizedQuestion(langCode);
      await _ttsService.speak(textToSpeak, localeCode: langCode);
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _voiceService.stopListening();
      _glowController.stop();
      setState(() {
        _isRecording = false;
        _hasRecording = _recordedText.trim().isNotEmpty;
        _saveStatus = '';
        _showImproveStory = false;
      });
      if (!_hasRecording) {
        _showErrorDialog();
      } else {
        _storageService.saveMemory(
          profileId: widget.profile.id,
          chapterId: widget.chapterId,
          questionId: _currentQuestion!.id,
          originalTranscript: _recordedText.trim(),
        );
      }
    } else {
      await _voiceService.startListening(
        onResult: (text) {
          if (mounted) {
            setState(() {
              _recordedText = text;
              _textController.text = text;
            });
          }
        },
        localeId: _getLocaleId(),
      );
      _glowController.repeat(reverse: true);
      setState(() {
        _isRecording = true;
        _hasRecording = false;
        _recordedText = '';
      });
    }
  }

  String _getLocaleId() {
    final langCode = localeProvider.locale.languageCode;
    final localeMap = {
      'en': 'en-US',
      'hi': 'hi-IN',
      'gu': 'gu-IN',
      'es': 'es-ES',
      'mr': 'mr-IN',
      'ta': 'ta-IN',
      'te': 'te-IN',
      'ml': 'ml-IN',
      'or': 'or-IN',
      'pa': 'pa-IN',
      'bn': 'bn-IN',
      'kn': 'kn-IN',
    };
    return localeMap[langCode] ?? 'en-US';
  }

  void _retryRecording() {
    setState(() {
      _recordedText = '';
      _hasRecording = false;
      _saveStatus = '';
      _showImproveStory = false;
    });
  }

  void _onTextChanged(String val) {
    setState(() {
      _recordedText = val;
      _saveStatus = 'Saving...';
    });
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      _storageService.saveMemory(
        profileId: widget.profile.id,
        chapterId: widget.chapterId,
        questionId: _currentQuestion!.id,
        editedTranscript: val,
        lastEdited: DateTime.now(),
      );
      setState(() => _saveStatus = '✓ Saved');
    });
  }

  void _approveMemory() async {
    if (_recordedText.trim().isEmpty) {
      _showErrorDialog();
      return;
    }
    final q = _currentQuestion;
    if (q == null) return;

    setState(() => _isSaving = true);
    
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _storageService.saveMemory(
      profileId: widget.profile.id,
      chapterId: widget.chapterId,
      questionId: q.id,
      editedTranscript: _recordedText.trim(),
      lastEdited: DateTime.now(),
      isApproved: true,
      approvedAt: DateTime.now(),
    );

    setState(() => _isSaving = false);

    if (_recordedText.trim().length >= 50) {
      _storageService.incrementMilestone(widget.profile.id, 'stories');
    }
    if (_currentQuestionIndex >= 2) {
      _storageService.incrementMilestone(widget.profile.id, 'sessions');
    }

    setState(() => _questionsAnswered++);

    // Check break reminder
    if (_sessionStartTime != null) {
      final elapsed = DateTime.now().difference(_sessionStartTime!);
      if (elapsed.inMinutes >= _breakReminderMinutes) {
        setState(() => _showBreakReminder = true);
        return;
      }
    }

    // Show memory pause
    setState(() => _showMemoryPause = true);
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(T.tr('ok')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToNextQuestion() {
    setState(() => _showMemoryPause = false);
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _recordedText = '';
        _hasRecording = false;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _speakQuestion();
      });
    } else {
      _finishChapter();
    }
  }

  void _finishChapter() {
    final responses = _storageService.getMemoriesForProfile(widget.profile.id);
    final templateService = TemplateBookService(_storageService);
    final book = templateService.generateBook(widget.profile, responses);

    Navigator.pushReplacement(
      context,
      PageTurnRoute(
        page: CelebrationScreen(profile: widget.profile, book: book),
      ),
    );
  }

  void _continueAfterBreak() {
    setState(() {
      _showBreakReminder = false;
      _sessionStartTime = DateTime.now();
    });
    _goToNextQuestion();
  }

  void _takeBreak() {
    Navigator.pop(context);
  }

  Widget _buildProgressIndicator() {
    if (_questions.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_questions.length, (index) {
        final isActive = index == _currentQuestionIndex;
        final isPast = index < _currentQuestionIndex;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 10,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: isActive || isPast ? AppColors.primary : AppColors.divider,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (_showBreakReminder) {
      return _buildBreakReminderScreen();
    }
    if (_showMemoryPause) {
      return _buildMemoryPauseScreen();
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Voice instructions button
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, size: 28),
            onPressed: _speakQuestion,
            tooltip: T.tr('readAloud'),
          ),
        ],
      ),
      body: _currentQuestion == null
          ? Center(
              child: Text(
                T.tr('noQuestionsAvailable'),
                style: AppTypography.body,
              ),
            )
          : SafeArea(
              child: ResponsiveBuilder(
                compact: (context) => _buildCompactLayout(),
                medium: (context) => _buildMediumLayout(context),
              ),
            ),
    );
  }

  Widget _buildCompactLayout() {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.m),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeader(),
                const SizedBox(height: AppSpacing.xxl),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  _currentQuestion!.getLocalizedQuestion(localeProvider.locale.languageCode),
                  textAlign: TextAlign.center,
                  style: AppTypography.question.copyWith(fontSize: 32),
                ),
                const SizedBox(height: AppSpacing.xxl),
                const SizedBox(height: AppSpacing.xxl),
                if (_isRecording)
                  _buildRecordingState(compact: true)
                else if (_hasRecording)
                  _buildReviewState(compact: true)
                else
                  _buildIdleState(),
                const SizedBox(height: AppSpacing.xl),
                _buildContinueLaterButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediumLayout(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AdaptiveSpacing.horizontalPadding(context),
        vertical: AppSpacing.xl,
      ),
      child: TwoColumnLayout(
        spacing: 48,
        leftChild: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const Spacer(),
            Text(
              _currentQuestion!.getLocalizedQuestion(localeProvider.locale.languageCode),
              textAlign: TextAlign.left,
              style: AppTypography.question.copyWith(fontSize: 36),
            ),
            const Spacer(),
            if (_isRecording)
              _buildRecordingState(compact: false)
            else if (_hasRecording)
              _buildReviewState(compact: false)
            else
              _buildIdleState(),
            const SizedBox(height: AppSpacing.xxl),
            _buildContinueLaterButton(),
          ],
        ),
        rightChild: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_hasRecording) ...[
              Text(
                'This is exactly how it will appear in your memoir.',
                style: AppTypography.caption.copyWith(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.l),
            ],
            MemoirCard(
              title: _currentQuestion?.question ?? 'Memory Preserved',
              text: _recordedText.isNotEmpty ? _recordedText : '...',
              parentName: widget.profile.name,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final chapter = _storageService.getChapterById(widget.chapterId);
    final chapterTitle = chapter != null
        ? chapter.getLocalizedTitle(localeProvider.locale.languageCode)
        : '';
    return Column(
      children: [
        Text(
          chapterTitle,
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(fontSize: 20, color: AppColors.textLight),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${T.tr('question')} ${_currentQuestionIndex + 1} ${T.tr('of')} ${_questions.length}',
          textAlign: TextAlign.center,
          style: AppTypography.caption,
        ),
        const SizedBox(height: AppSpacing.s),
        _buildProgressIndicator(),
      ],
    );
  }

  Widget _buildContinueLaterButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          minimumSize: const Size(double.infinity, AppTouchTargets.min),
        ),
        onPressed: () => Navigator.pop(context),
        child: Text(
          T.tr('continueLater'),
          style: AppTypography.button.copyWith(color: AppColors.textLight),
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
            width: AppTouchTargets.large,
            height: AppTouchTargets.large,
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
            child: const Icon(Icons.mic_rounded, color: Colors.white, size: AppIcons.xl),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Text(
          T.tr('recordLabel'),
          style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          T.tr('tapToBeginStory'),
          style: AppTypography.caption,
        ),
        const SizedBox(height: AppSpacing.l),
        Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppRadius.m),
          ),
          child: Row(
            children: [
              const Icon(Icons.privacy_tip_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  'Your phone may use its built-in speech service for transcription. Your recordings remain stored only on your device unless you choose to share them.',
                  style: AppTypography.caption.copyWith(color: AppColors.primary, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingState({required bool compact}) {
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
                  width: AppTouchTargets.large,
                  height: AppTouchTargets.large,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.error,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withValues(alpha: 0.4),
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
        const SizedBox(height: AppSpacing.m),
        VoiceWaveformWidget(isRecording: _isRecording, height: 36),
        const SizedBox(height: AppSpacing.m),
        Text(
          T.tr('recordingLabel'),
          style: AppTypography.body.copyWith(fontWeight: FontWeight.w600, color: AppColors.error),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          T.tr('listening'),
          style: AppTypography.caption,
        ),
        if (compact && _recordedText.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.m),
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.m),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              _recordedText,
              style: AppTypography.body.copyWith(fontSize: 20),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewState({required bool compact}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Reassurance UI
        Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.m),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                  const SizedBox(width: AppSpacing.s),
                  Text(
                    'Voice recorded',
                    style: AppTypography.body.copyWith(fontWeight: FontWeight.w600, color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Transcript generated',
                style: AppTypography.caption.copyWith(color: Colors.green),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'You can edit anything before saving.',
                style: AppTypography.caption.copyWith(color: Colors.green),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        
        // Editable Transcript
        Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.m),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _textController,
                onChanged: _onTextChanged,
                maxLines: null,
                style: AppTypography.body.copyWith(fontSize: 18),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (_saveStatus.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _saveStatus,
                  style: AppTypography.caption.copyWith(
                    color: _saveStatus == '✓ Saved' ? Colors.green : AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),

        // Improve My Story Helper
        Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.m),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Would you like to add more detail?',
                    style: AppTypography.body.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => setState(() => _showImproveStory = true),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Yes',
                          style: AppTypography.button.copyWith(
                            color: _showImproveStory ? AppColors.primary : AppColors.textLight,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _showImproveStory = false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'No',
                          style: AppTypography.button.copyWith(
                            color: !_showImproveStory ? AppColors.primary : AppColors.textLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (_showImproveStory && (_currentQuestion?.followUps.isNotEmpty ?? false)) ...[
                const SizedBox(height: AppSpacing.s),
                const Divider(),
                const SizedBox(height: AppSpacing.s),
                ..._currentQuestion!.followUps.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: AppColors.primary, fontSize: 16)),
                      Expanded(
                        child: Text(
                          p,
                          style: AppTypography.caption.copyWith(color: AppColors.primary, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.l),

        // Live Memoir Preview (Compact only)
        if (compact) ...[
          Text(
            'This is exactly how it will appear in your memoir.',
            style: AppTypography.caption.copyWith(fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s),
          MemoirCard(
            title: _currentQuestion?.question ?? 'Memory Preserved',
            text: _recordedText.isNotEmpty ? _recordedText : '...',
            parentName: widget.profile.name,
          ),
          const SizedBox(height: AppSpacing.l),
        ],

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _retryRecording,
                icon: const Icon(Icons.refresh_rounded, size: 24),
                label: Text(T.tr('tryAgain')),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _approveMemory,
                icon: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_rounded, size: 24),
                label: const Text('Approve & Continue'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMemoryPauseScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withValues(alpha: 0.15),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.accent,
                    size: 40,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  T.tr('thankYouMemory'),
                  textAlign: TextAlign.center,
                  style: AppTypography.display.copyWith(height: 1.3),
                ),
                const SizedBox(height: AppSpacing.m),
                Text(
                  T.tr('memorySavedCount').replaceAll('{count}', '$_questionsAnswered'),
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(color: AppColors.textLight),
                ),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _goToNextQuestion,
                    child: Text(T.tr('nextQuestion')),
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

  Widget _buildBreakReminderScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    Icons.coffee_rounded,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  T.tr('breakTitle'),
                  textAlign: TextAlign.center,
                  style: AppTypography.display.copyWith(height: 1.3),
                ),
                const SizedBox(height: AppSpacing.m),
                Text(
                  T.tr('breakSubtitle'),
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(color: AppColors.textLight),
                ),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _continueAfterBreak,
                    child: Text(T.tr('continueRecording')),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _takeBreak,
                    child: Text(T.tr('takeBreak')),
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
