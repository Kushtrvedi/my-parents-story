import 'package:flutter/material.dart';

import '../design_system/design_system.dart';
import '../l10n/translations.dart';
import '../models/memory.dart';
import '../models/parent_profile.dart';
import 'package:share_plus/share_plus.dart';

class ShareMemoryScreen extends StatelessWidget {
  final ParentProfile profile;
  final Memory memory;

  const ShareMemoryScreen({
    super.key,
    required this.profile,
    required this.memory,
  });

  void _shareQuote(BuildContext context) {
    // In a real app, this would use a widget-to-image package to share the actual designed card.
    // For now, we share the text directly.
    final textToShare = '"${memory.answer}"\n\n— ${profile.name}\nShared from My Parents\' Story';
    Share.share(textToShare);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(T.tr('shareAMemory')),
        leading: IconButton(
          icon: const Icon(Icons.close, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: AdaptiveCenteredBox(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.m),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Beautiful Quote Card
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(AppRadius.l),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.format_quote_rounded, size: AppIcons.xl, color: AppColors.accent),
                            const SizedBox(height: AppSpacing.l),
                            Text(
                              '"${memory.answer}"',
                              textAlign: TextAlign.center,
                              style: AppTypography.display.copyWith(
                                color: AppColors.text,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Text(
                              '— ${profile.name}',
                              style: AppTypography.body.copyWith(
                                color: AppColors.textLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      // Actions
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.ios_share_rounded),
                          label: Text(T.tr('shareThisMoment')),
                          onPressed: () => _shareQuote(context),
                        ),
                      ),
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
