import 'package:flutter/material.dart';

import '../design_system/design_system.dart';
import '../l10n/translations.dart';
import '../main.dart';
import '../models/parent_profile.dart';
import '../services/storage_service.dart';
import 'profile_type_screen.dart';
import 'life_journey_screen.dart';
import '../design_system/navigation/page_turn_route.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _storageService = StorageService();
  List<ParentProfile> _existingProfiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  void _loadProfiles() {
    setState(() {
      _existingProfiles = _storageService.getAllProfiles();
    });
  }

  void _continueProfile(ParentProfile profile) {
    Navigator.push(
      context,
      PageTurnRoute(
        page: LifeJourneyScreen(profile: profile),
      ),
    ).then((_) => _loadProfiles());
  }

  void _startNew() {
    Navigator.push(
      context,
      PageTurnRoute(page: const ProfileTypeScreen()),
    ).then((_) => _loadProfiles());
  }

  @override
  Widget build(BuildContext context) {
    final hasProfiles = _existingProfiles.isNotEmpty;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl, vertical: AppSpacing.l),
        child: AdaptiveCenteredBox(
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),
              // App Brand Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_stories_rounded,
                        size: 16, color: AppColors.primary),
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
              // Main Headline
              Text(
                hasProfiles ? T.tr('welcomeBack') : T.tr('welcomeMessage'),
                textAlign: TextAlign.center,
                style:
                    AppTypography.display.copyWith(fontSize: 34, height: 1.3),
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Not an app people download. A gift families give.',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // AHA MOMENT #1: HEIRLOOM BOOK TEASER CARD
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.parchment,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.amberGold.withValues(alpha: 0.4),
                      width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.amberGold, size: 18),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'THE FINISHED HEIRLOOM',
                            textAlign: TextAlign.center,
                            style: AppTypography.caption.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: AppColors.amberGold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.star_rounded,
                            color: AppColors.amberGold, size: 18),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '“Happiness was never about having more. It was about having each other.”',
                      textAlign: TextAlign.center,
                      style: AppTypography.heading.copyWith(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: AppColors.primary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '— Chapter 1: Early Childhood Memories',
                      style: AppTypography.caption
                          .copyWith(fontSize: 13, color: AppColors.textLight),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Trust Badges Pill Chips
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTrustChip(Icons.lock_outline_rounded, '100% Private'),
                  _buildTrustChip(Icons.wifi_off_rounded, 'Works Offline'),
                  _buildTrustChip(
                      Icons.volunteer_activism_rounded, 'Built for Families'),
                ],
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
                          icon: const Icon(Icons.play_arrow_rounded,
                              size: AppIcons.l, color: AppColors.primary),
                          label: Text(
                            '${T.tr('continueStory')} — ${profile.name}',
                            style: AppTypography.body
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.l,
                                horizontal: AppSpacing.l),
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                      ),
                    )),
                const SizedBox(height: AppSpacing.m),
                Text(
                  T.tr('or'),
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textLight),
                ),
                const SizedBox(height: AppSpacing.m),
              ],

              // Main CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startNew,
                  icon: const Icon(Icons.auto_stories_rounded, size: 24),
                  label: Text(
                    hasProfiles ? T.tr('startNewStory') : T.tr('beginStory'),
                    style: AppTypography.button,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Language selector
              Text(
                'Change Language',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              GestureDetector(
                onTap: () => _showLanguagePicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m, vertical: AppSpacing.s),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppRadius.m),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language_rounded,
                          size: 20, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          localeProvider.getLanguageName(
                              localeProvider.locale.languageCode),
                          style: AppTypography.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
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

  Widget _buildTrustChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text),
            ),
          ),
        ],
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
              final isSelected =
                  localeProvider.locale.languageCode == lang['code'];
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
                    ? const Icon(Icons.check_circle,
                        color: AppColors.primary, size: AppIcons.m)
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.s),
              );
            }),
            const SizedBox(height: AppSpacing.m),
          ],
        ),
      ),
    );
  }
}
