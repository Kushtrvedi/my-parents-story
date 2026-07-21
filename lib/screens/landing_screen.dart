import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../design_system/design_system.dart';
import '../l10n/translations.dart';
import '../main.dart';
import 'profile_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // Gentle icon
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
              const SizedBox(height: 56),
              // Headline
              Text(
                T.tr('tagline'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              Text(
                T.tr('subtagline'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textLight,
                    ),
              ),
              const SizedBox(height: 72),
              // Two simple choices
              SizedBox(
                width: double.infinity,
                height: 76,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(parentType: 'mom'),
                    ),
                  ),
                  child: Text(T.tr('startMom')),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 76,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(parentType: 'dad'),
                    ),
                  ),
                  child: Text(T.tr('startDad')),
                ),
              ),
              const SizedBox(height: 48),
              // Language — calm, small
              GestureDetector(
                onTap: () => _showLanguagePicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        localeProvider.getLanguageName(localeProvider.locale.languageCode),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 60),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 28),
            Text(T.tr('switchLang'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            ...localeProvider.availableLanguages.map((lang) {
              final isSelected = localeProvider.locale.languageCode == lang['code'];
              return ListTile(
                onTap: () {
                  localeProvider.setLocale(Locale(lang['code']!));
                  Navigator.pop(ctx);
                },
                title: Text(
                  '${lang['native']}  ·  ${lang['name']}',
                  style: TextStyle(
                    fontSize: 22,
                    color: isSelected ? AppColors.primary : AppColors.text,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: AppColors.primary, size: 26)
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
