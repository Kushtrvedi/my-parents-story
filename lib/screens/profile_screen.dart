import 'package:flutter/material.dart';

import '../design_system/design_system.dart';
import '../design_system/navigation/page_turn_route.dart';
import '../models/parent_profile.dart';
import '../l10n/translations.dart';
import '../services/storage_service.dart';
import 'life_journey_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String parentType;
  const ProfileScreen({super.key, required this.parentType});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthYearController = TextEditingController();
  final _cityController = TextEditingController();
  final _storageService = StorageService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _birthYearController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final profile = _storageService.createProfile(
      name: _nameController.text.trim(),
      parentType: widget.parentType,
      birthYear: _birthYearController.text.trim(),
      city: _cityController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageTurnRoute(page: LifeJourneyScreen(profile: profile)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(T.tr('profileTitle')),
      ),
      body: AdaptiveCenteredBox(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Photo placeholder — gentle
                Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      constraints:
                          const BoxConstraints(minWidth: 120, minHeight: 120),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent.withValues(alpha: 0.15),
                        border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.3),
                            width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined,
                              size: 28,
                              color: AppColors.accent.withValues(alpha: 0.6)),
                          const SizedBox(height: 4),
                          Text(T.tr('addPhoto'),
                              style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      AppColors.accent.withValues(alpha: 0.6))),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                    child: Text(T.tr('optional'),
                        style: Theme.of(context).textTheme.bodySmall)),
                const SizedBox(height: 48),
                // Name
                Text(T.tr('nameLabel'),
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(hintText: T.tr('nameHint')),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? T.tr('enterName')
                      : null,
                ),
                const SizedBox(height: 36),
                // Birth year
                Text(T.tr('birthYearLabel'),
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _birthYearController,
                  keyboardType: TextInputType.datetime,
                  maxLength: 10,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                      hintText: T.tr('birthYearHint'), counterText: ''),
                ),
                const SizedBox(height: 36),
                // City
                Text(T.tr('cityLabel'),
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _cityController,
                  textCapitalization: TextCapitalization.words,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(hintText: T.tr('cityHint')),
                ),
                const SizedBox(height: 56),
                // Single action
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Text(T.tr('beginStory'), textAlign: TextAlign.center),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
