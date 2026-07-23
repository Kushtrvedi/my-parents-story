import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../services/conversation_coordinator.dart';

class DeveloperOptionsScreen extends StatefulWidget {
  const DeveloperOptionsScreen({super.key});

  @override
  State<DeveloperOptionsScreen> createState() => _DeveloperOptionsScreenState();
}

class _DeveloperOptionsScreenState extends State<DeveloperOptionsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final ConversationCoordinator _coordinator = ConversationCoordinator();
  String _activeEngineName = 'Checking...';

  @override
  void initState() {
    super.initState();
    _checkActiveEngine();
  }

  Future<void> _checkActiveEngine() async {
    final engine = await _coordinator.getActiveEngine();
    setState(() {
      _activeEngineName = '${engine.runtimeType} (${engine.modeName})';
    });
  }

  void _saveApiKey() {
    _coordinator.setCloudApiKey(_apiKeyController.text.trim());
    _checkActiveEngine();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API Key saved. Conversation Engine re-evaluated.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Developer Options'),
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
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.engineering, color: AppColors.primary, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Active Conversation Engine', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(_activeEngineName, style: const TextStyle(color: AppColors.textLight)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Cloud Fallback (Gemini)', style: AppTypography.heading.copyWith(fontSize: 20)),
            const SizedBox(height: 8),
            const Text(
              'Input a Gemini API Key to enable the CloudConversationEngine on unsupported devices.',
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
          ],
        ),
      ),
    );
  }
}
