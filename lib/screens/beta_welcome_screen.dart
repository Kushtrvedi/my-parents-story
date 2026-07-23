import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../l10n/translations.dart';
import 'setup_wizard_screen.dart';
import 'landing_screen.dart';
import '../services/speech_setup_service.dart';

import 'developer_options_screen.dart';

class BetaWelcomeScreen extends StatefulWidget {
  const BetaWelcomeScreen({super.key});

  @override
  State<BetaWelcomeScreen> createState() => _BetaWelcomeScreenState();
}

class _BetaWelcomeScreenState extends State<BetaWelcomeScreen> {
  int _tapCount = 0;

  void _startStory(BuildContext context) {
    final speechService = SpeechSetupService();
    final showSetup = !speechService.isSetupComplete;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => showSetup ? const SetupWizardScreen() : const LandingScreen(),
      ),
    );
  }

  void _handleLogoTap() {
    _tapCount++;
    if (_tapCount >= 5) {
      _tapCount = 0;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const DeveloperOptionsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AdaptiveSpacing.horizontalPadding(context),
            vertical: AppSpacing.xxl,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              GestureDetector(
                onTap: _handleLogoTap,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Welcome to the Private Family Beta',
                textAlign: TextAlign.center,
                style: AppTypography.display,
              ),
              const SizedBox(height: AppSpacing.l),
              Text(
                'Thank you for helping us test My Parents\' Story. Your feedback will help us preserve family stories for millions of families around the world.',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: AppColors.textLight,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _startStory(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.m),
                  ),
                ),
                child: Text(
                  'Start My Parent\'s Story',
                  style: AppTypography.button,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
