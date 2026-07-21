import 'dart:io';
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
  bool _onDeviceAvailable = false;
  bool _offlineLanguageReady = false;
  List<String> _installedLanguages = [];

  @override
  void initState() {
    super.initState();
    _startSetup();
  }

  Future<void> _startSetup() async {
    setState(() => _isChecking = true);

    // Step 1: Microphone
    _micGranted = await _speechService.requestMicrophonePermission();
    setState(() => _currentStep = 1);
    await Future.delayed(const Duration(milliseconds: 600));

    // Step 2: Speech recognition check
    final result = await _speechService.checkDeviceReadiness(
      languageCode: localeProvider.locale.languageCode,
    );
    _speechAvailable = result.speechAvailable;
    _onDeviceAvailable = result.onDeviceAvailable;
    _offlineLanguageReady = result.offlineLanguageReady;
    _installedLanguages = result.installedLanguages;

    setState(() => _currentStep = 2);
    await Future.delayed(const Duration(milliseconds: 600));

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
    if (Platform.isAndroid) {
      try {
        await const MethodChannel('com.myparentsstory/setup').invokeMethod('openSpeechSettings');
      } catch (_) {
        // Fallback
      }
    }
  }

  void _openLanguageDownload() async {
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // App icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                T.tr('setupTitle'),
                textAlign: TextAlign.center,
                style: AppTypography.display,
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                T.tr('setupSubtitle'),
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: AppColors.textLight),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Readiness Check Cards
              if (_isChecking && _currentStep < 4) ...[
                _buildCheckingIndicator(),
              ] else ...[
                _buildReadinessCards(),
              ],
              const Spacer(flex: 2),
              // Bottom button
              if (_currentStep == 4 && !_isChecking) ...[
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
    );
  }

  Widget _buildCheckingIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.l),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Text(
            T.tr('checkingDevice'),
            style: AppTypography.body,
          ),
        ],
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
        ),
        const SizedBox(height: AppSpacing.s),
        _buildCheckItem(
          icon: Icons.record_voice_over_rounded,
          label: T.tr('speechAvailable'),
          isReady: _speechAvailable,
        ),
        const SizedBox(height: AppSpacing.s),
        _buildCheckItem(
          icon: Icons.language_rounded,
          label: T.tr('offlineLanguage'),
          isReady: _offlineLanguageReady,
        ),
        const SizedBox(height: AppSpacing.s),
        _buildCheckItem(
          icon: Icons.phone_android_rounded,
          label: T.tr('storageReady'),
          isReady: true,
        ),
        if (!allReady) ...[
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(
          color: isReady
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isReady
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
            ),
            child: Icon(
              isReady ? Icons.check_rounded : Icons.close_rounded,
              color: isReady ? AppColors.success : AppColors.error,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(
              label,
              style: AppTypography.body.copyWith(
                color: isReady ? AppColors.text : AppColors.textLight,
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
