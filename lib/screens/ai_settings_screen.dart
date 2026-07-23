import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../services/ai_coordinator.dart';
import '../services/ai/ai_engine.dart';

class AiSettingsScreen extends StatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  State<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends State<AiSettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final AiCoordinator _coordinator = AiCoordinator();
  String _activeEngineName = 'Checking...';

  @override
  void initState() {
    super.initState();
    _checkActiveEngine();
  }

  Future<void> _checkActiveEngine() async {
    final engine = await _coordinator.getActiveEngine();
    setState(() {
      _activeEngineName = engine.name;
    });
  }

  void _saveApiKey() {
    _coordinator.setCloudApiKey(_apiKeyController.text.trim());
    _checkActiveEngine();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API Key saved. AI Engine re-evaluated.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Engine Settings'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.psychology, color: AppColors.primary, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Active AI Engine', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(_activeEngineName, style: const TextStyle(color: AppColors.textLight)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Cloud AI Fallback (Gemini)', style: AppTypography.heading.copyWith(fontSize: 20)),
            const SizedBox(height: 8),
            const Text(
              'If your browser does not support on-device Gemini Nano, you can provide a Gemini API Key to enable cloud AI follow-ups. Your key is stored locally.',
              style: TextStyle(color: AppColors.textLight),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(
                labelText: 'Gemini API Key',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveApiKey,
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            Text('Browser AI (Gemini Nano)', style: AppTypography.heading.copyWith(fontSize: 20)),
            const SizedBox(height: 8),
            const Text(
              'To use 100% offline, on-device AI in Chrome (Dev/Canary), enable:\n\n'
              '1. chrome://flags/#prompt-api-for-gemini-nano\n'
              '2. chrome://flags/#optimization-guide-on-device-model\n\n'
              'Once enabled, this app will automatically switch to Browser AI.',
              style: TextStyle(color: AppColors.textLight, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
