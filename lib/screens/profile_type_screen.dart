import 'package:flutter/material.dart';

import '../design_system/design_system.dart';
import '../l10n/translations.dart';
import 'profile_screen.dart';

class ProfileTypeScreen extends StatelessWidget {
  const ProfileTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: AdaptiveCenteredBox(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text(
                T.tr('whoToPreserve'),
                style: AppTypography.display,
              ),
              const SizedBox(height: AppSpacing.xxl),
              _buildOption(context, T.tr('parentMom'), 'mom'),
              const SizedBox(height: AppSpacing.m),
              _buildOption(context, T.tr('parentDad'), 'dad'),
              const SizedBox(height: AppSpacing.m),
              _buildOption(context, T.tr('parentGrandma'), 'grandma'),
              const SizedBox(height: AppSpacing.m),
              _buildOption(context, T.tr('parentGrandpa'), 'grandpa'),
              const SizedBox(height: AppSpacing.m),
              _buildOption(context, T.tr('parentSpecial'), 'special'),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, String label, String type) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
          alignment: Alignment.centerLeft,
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileScreen(parentType: type),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
