import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../l10n/translations.dart';
import 'setup_wizard_screen.dart';
import 'landing_screen.dart';
import '../services/speech_setup_service.dart';

class BetaWelcomeScreen extends StatelessWidget {
  const BetaWelcomeScreen({super.key});

  void _startStory(BuildContext context) {
    final speechService = SpeechSetupService();
    final showSetup = !speechService.isSetupComplete;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => showSetup ? const SetupWizardScreen() : const LandingScreen(),
      ),
    );
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
              Container(
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
