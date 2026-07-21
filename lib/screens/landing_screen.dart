import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design_system/design_system.dart';
import '../l10n/translations.dart';
import '../main.dart';
import '../models/parent_profile.dart';
import '../services/storage_service.dart';
import '../services/speech_setup_service.dart';
import 'profile_type_screen.dart';
import 'life_journey_screen.dart';
import 'setup_wizard_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _storageService = StorageService();
  final _speechService = SpeechSetupService();
  List<ParentProfile> _existingProfiles = [];

  @override
  void initState() {
    super.initState();
    _checkSetup();
    _loadProfiles();
  }

  Future<void> _checkSetup() async {
    if (!_speechService.isSetupComplete) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SetupWizardScreen()),
        );
      }
    }
  }

  void _loadProfiles() {
    setState(() {
      _existingProfiles = _storageService.getAllProfiles();
    });
  }

  void _continueProfile(ParentProfile profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LifeJourneyScreen(profile: profile),
      ),
    ).then((_) => _loadProfiles());
  }

  void _startNew() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileTypeScreen()),
    ).then((_) => _loadProfiles());
  }

  @override
  Widget build(BuildContext context) {
    final hasProfiles = _existingProfiles.isNotEmpty;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              // Gentle icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  size: AppIcons.xxl,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Emotional Core Message
              Text(
                hasProfiles ? T.tr('welcomeBack') : T.tr('welcomeMessage'),
                textAlign: TextAlign.center,
                style: AppTypography.display.copyWith(height: 1.3),
              ),
              const SizedBox(height: AppSpacing.m),
              if (hasProfiles)
                Text(
                  T.tr('continueWhereLeftOff'),
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(color: AppColors.textLight),
                ),
              const SizedBox(height: AppSpacing.xxl),
              // Trust Message
              Container(
                padding: const EdgeInsets.all(AppSpacing.l),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadius.l),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: AppColors.primary, size: AppIcons.l),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Text(
                        T.tr('privacyTrust'),
                        style: AppTypography.caption.copyWith(color: AppColors.text),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Existing profiles (continue)
              if (hasProfiles) ...[
                ..._existingProfiles.map((profile) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.m),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _continueProfile(profile),
                      icon: const Icon(Icons.play_arrow_rounded, size: AppIcons.l),
                      label: Text(
                        '${T.tr('continueStory')} — ${profile.name}',
                        style: AppTypography.body,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.l, horizontal: AppSpacing.l),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ),
                )),
                const SizedBox(height: AppSpacing.m),
                Text(
                  T.tr('or'),
                  style: AppTypography.caption.copyWith(color: AppColors.textLight),
                ),
                const SizedBox(height: AppSpacing.m),
              ],
              // Start Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startNew,
                  child: Text(
                    hasProfiles ? T.tr('startNewStory') : T.tr('beginStory'),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Language
              GestureDetector(
                onTap: () => _showLanguagePicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppRadius.m),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language_rounded, size: 24, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        localeProvider.getLanguageName(localeProvider.locale.languageCode),
                        style: AppTypography.caption.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.l)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(T.tr('switchLang'), style: AppTypography.heading),
            const SizedBox(height: AppSpacing.l),
            ...localeProvider.availableLanguages.map((lang) {
              final isSelected = localeProvider.locale.languageCode == lang['code'];
              return ListTile(
                onTap: () {
                  localeProvider.setLocale(Locale(lang['code']!));
                  Navigator.pop(ctx);
                },
                title: Text(
                  '${lang['native']}  ·  ${lang['name']}',
                  style: AppTypography.body.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.text,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: AppColors.primary, size: AppIcons.m)
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
              );
            }),
            const SizedBox(height: AppSpacing.m),
          ],
        ),
      ),
    );
  }
}
