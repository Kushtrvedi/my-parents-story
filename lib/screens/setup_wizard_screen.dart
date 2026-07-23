import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/design_system.dart';
import '../l10n/translations.dart';
import '../services/speech_setup_service.dart';
import '../main.dart';
import 'landing_screen.dart';

class SetupWizardScreen extends StatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  final _speechService = SpeechSetupService();
  int _currentStep = 0;
  bool _isChecking = false;

  bool _micGranted = false;
  bool _speechAvailable = false;
  bool _offlineLanguageReady = false;

  @override
  void initState() {
    super.initState();
    _startSetup();
  }

  Future<void> _startSetup() async {
    setState(() => _isChecking = true);

    // Step 1: Microphone
    setState(() => _currentStep = 1);
    await Future.delayed(const Duration(milliseconds: 600));
    _micGranted = await _speechService.requestMicrophonePermission();
    
    // Step 2: Speech recognition check
    setState(() => _currentStep = 2);
    await Future.delayed(const Duration(milliseconds: 600));
    final result = await _speechService.checkDeviceReadiness(
      languageCode: localeProvider.locale.languageCode,
    );
    _speechAvailable = result.speechAvailable;
    _offlineLanguageReady = result.offlineLanguageReady;

    // Step 3: Language check
    setState(() => _currentStep = 3);
    await Future.delayed(const Duration(milliseconds: 600));

    // Step 4: Ready
    setState(() {
      _isChecking = false;
      _currentStep = 4;
    });
  }

  Future<void> _retryChecks() async {
    setState(() {
      _isChecking = true;
      _currentStep = 0;
    });
    await _startSetup();
  }

  void _openSettings() async {
    if (kIsWeb) return;
    if (Platform.isAndroid) {
      try {
        await const MethodChannel('com.myparentsstory/setup').invokeMethod('openSpeechSettings');
      } catch (_) {
        // Fallback
      }
    }
  }

  void _openLanguageDownload() async {
    if (kIsWeb) return;
    if (Platform.isAndroid) {
      try {
        await const MethodChannel('com.myparentsstory/setup').invokeMethod('openLanguagePackSettings');
      } catch (_) {
        // Fallback
      }
    }
  }

  void _finish() async {
    await _speechService.markSetupComplete();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LandingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        children: [
                          const SizedBox(height: AppSpacing.xl),
                          
                          // App Brand Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.auto_stories_rounded, size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    "REYOU - MY PARENTS' STORY",
                                    style: AppTypography.caption.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.l),
                          
                          // Progress indicator
                          if (_currentStep < 4) ...[
                            Text(
                              'Step ${_currentStep == 0 ? 1 : _currentStep} of 4',
                              style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Preparing your phone',
                              style: AppTypography.caption.copyWith(color: AppColors.textLight),
                            ),
                            const SizedBox(height: AppSpacing.l),
                          ] else ...[
                            const SizedBox(height: AppSpacing.xxl),
                          ],

                          // App icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: 0.08),
                            ),
                            child: const Icon(
                              Icons.auto_stories_rounded,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            T.tr('setupTitle'),
                            textAlign: TextAlign.center,
                            style: AppTypography.display,
                          ),
                          const SizedBox(height: AppSpacing.m),
                          Text(
                            'This usually takes less than 30 seconds.',
                            textAlign: TextAlign.center,
                            style: AppTypography.body.copyWith(color: AppColors.textLight),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          
                          // Readiness Check Cards
                          _buildReadinessCards(),
                          
                          const Spacer(),
                          
                          // Final Goal & Trust Card when checking
                          if (_currentStep < 4) ...[
                            _buildFinalGoalCard(),
                            const SizedBox(height: AppSpacing.l),
                            _buildTrustCard(),
                            const SizedBox(height: AppSpacing.xl),
                          ],

                          // Bottom button
                          if (_currentStep == 4 && !_isChecking) ...[
                            const SizedBox(height: AppSpacing.xl),
                            _buildTrustCard(),
                            const SizedBox(height: AppSpacing.xl),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _finish,
                                child: Text(T.tr('startMyStory')),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                          ],
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

  Widget _buildReadinessCards() {
    final allReady = _micGranted && _speechAvailable && _offlineLanguageReady;

    return Column(
      children: [
        _buildCheckItem(
          icon: Icons.mic_rounded,
          label: T.tr('micReady'),
          isReady: _micGranted,
          isChecking: _isChecking && _currentStep == 1,
          isPending: _currentStep < 1,
        ),
        const SizedBox(height: AppSpacing.s),
        _buildCheckItem(
          icon: Icons.record_voice_over_rounded,
          label: T.tr('speechAvailable'),
          isReady: _speechAvailable,
          isChecking: _isChecking && _currentStep == 2,
          isPending: _currentStep < 2,
        ),
        const SizedBox(height: AppSpacing.s),
        _buildCheckItem(
          icon: Icons.language_rounded,
          label: T.tr('offlineLanguage'),
          isReady: _offlineLanguageReady,
          isChecking: _isChecking && _currentStep == 3,
          isPending: _currentStep < 3,
        ),
        const SizedBox(height: AppSpacing.s),
        _buildCheckItem(
          icon: Icons.phone_android_rounded,
          label: T.tr('storageReady'),
          isReady: true,
          isChecking: false,
          isPending: false,
        ),
        
        if (!allReady && _currentStep == 4) ...[
          const SizedBox(height: AppSpacing.l),
          _buildRecoveryActions(),
        ],
      ],
    );
  }

  Widget _buildCheckItem({
    required IconData icon,
    required String label,
    required bool isReady,
    required bool isChecking,
    required bool isPending,
  }) {
    Color stateColor;
    Widget leadingWidget;
    String displayLabel = label;
    Color labelColor = AppColors.text;

    if (isPending) {
      stateColor = AppColors.divider;
      labelColor = AppColors.textLight;
      leadingWidget = Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.divider, width: 2),
        ),
      );
    } else if (isChecking) {
      stateColor = AppColors.primary;
      displayLabel = 'Checking...';
      leadingWidget = const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.primary,
        ),
      );
    } else if (isReady) {
      stateColor = AppColors.success;
      leadingWidget = Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.success.withValues(alpha: 0.1),
        ),
        child: const Icon(
          Icons.check_rounded,
          color: AppColors.success,
          size: 16,
        ),
      );
    } else {
      stateColor = AppColors.error;
      leadingWidget = Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.error.withValues(alpha: 0.1),
        ),
        child: const Icon(
          Icons.close_rounded,
          color: AppColors.error,
          size: 16,
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(
          color: (isReady || isChecking) 
              ? stateColor.withValues(alpha: 0.3)
              : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: leadingWidget,
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Align(
                alignment: Alignment.centerLeft,
                key: ValueKey(displayLabel),
                child: Text(
                  displayLabel,
                  style: AppTypography.body.copyWith(
                    color: labelColor,
                    fontWeight: (isChecking || isReady) ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          Icon(
            icon,
            color: isReady ? AppColors.success : AppColors.textLight,
            size: AppIcons.m,
          ),
        ],
      ),
    );
  }

  Widget _buildFinalGoalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(
            'Next',
            style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'You\'ll record your first family story.',
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrustCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: AppColors.textLight,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Private by Design',
                  style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600, color: AppColors.text),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Your recordings stay on your phone.\nNothing is uploaded unless you choose to share it.',
                  style: AppTypography.caption.copyWith(color: AppColors.textLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryActions() {
    return Column(
      children: [
        if (!_micGranted) ...[
          _buildRecoveryButton(
            label: T.tr('grantMicrophone'),
            onPressed: () async {
              await _speechService.requestMicrophonePermission();
              await _retryChecks();
            },
          ),
          const SizedBox(height: AppSpacing.s),
        ],
        if (!_speechAvailable) ...[
          _buildRecoveryButton(
            label: T.tr('openSpeechSettings'),
            onPressed: _openSettings,
          ),
          const SizedBox(height: AppSpacing.s),
        ],
        if (!_offlineLanguageReady) ...[
          _buildRecoveryButton(
            label: T.tr('downloadLanguagePack'),
            onPressed: _openLanguageDownload,
          ),
          const SizedBox(height: AppSpacing.s),
        ],
        TextButton(
          onPressed: _retryChecks,
          child: Text(
            T.tr('checkAgain'),
            style: AppTypography.button.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildRecoveryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
        ),
        child: Text(label),
      ),
    );
  }
}
