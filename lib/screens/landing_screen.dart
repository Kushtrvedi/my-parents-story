import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../l10n/translations.dart';
import '../main.dart';
import 'profile_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = T.tr;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.warmWhite, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent.withValues(alpha: 0.1),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      size: 56,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    t('tagline'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t('subtagline'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.secondaryText,
                        ),
                  ),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(parentType: 'mom'),
                        ),
                      ),
                      icon: const Icon(Icons.favorite, size: 28),
                      label: Text(t('startMom')),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(parentType: 'dad'),
                        ),
                      ),
                      icon: const Icon(Icons.favorite_border, size: 28),
                      label: Text(t('startDad')),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Language selector
                  GestureDetector(
                    onTap: () => _showLanguagePicker(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.language, size: 22, color: AppColors.accent),
                          const SizedBox(width: 8),
                          Text(
                            localeProvider.getLanguageName(localeProvider.locale.languageCode),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.accent,
                                ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.expand_more, size: 20, color: AppColors.accent),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 20),
            Text(
              T.tr('switchLang'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ...localeProvider.availableLanguages.map((lang) {
              final isSelected = localeProvider.locale.languageCode == lang['code'];
              return ListTile(
                onTap: () {
                  localeProvider.setLocale(Locale(lang['code']!));
                  Navigator.pop(ctx);
                },
                title: Text(
                  '${lang['native']} (${lang['name']})',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isSelected ? AppColors.accent : AppColors.primaryText,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: AppColors.accent, size: 28)
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
