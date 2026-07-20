import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../l10n/translations.dart';
import '../services/storage_service.dart';
import 'categories_screen.dart';

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

  String get _title => widget.parentType == 'mom' ? "Mother's Story" : "Father's Story";

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
        MaterialPageRoute(builder: (_) => CategoriesScreen(profile: profile)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = T.tr;
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentLight,
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 3),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 36, color: AppColors.accent.withValues(alpha: 0.6)),
                      const SizedBox(height: 4),
                      Text(t('addPhoto'), style: TextStyle(fontSize: 13, color: AppColors.accent.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(child: Text(t('optional'), style: Theme.of(context).textTheme.bodySmall)),
              const SizedBox(height: 44),
              Text(t('nameLabel'), style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(hintText: t('nameHint')),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 28),
              Text(t('birthYearLabel'), style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              TextFormField(
                controller: _birthYearController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(hintText: t('birthYearHint'), counterText: ''),
              ),
              const SizedBox(height: 28),
              Text(t('cityLabel'), style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              TextFormField(
                controller: _cityController,
                textCapitalization: TextCapitalization.words,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(hintText: t('cityHint')),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : Text(t('beginStory')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
