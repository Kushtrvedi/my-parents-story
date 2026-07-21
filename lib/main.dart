import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/app_theme.dart';
import 'services/local_storage.dart';
import 'services/locale_provider.dart';
import 'services/speech_setup_service.dart';
import 'screens/landing_screen.dart';
import 'screens/setup_wizard_screen.dart';

final localeProvider = LocaleProvider();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  await localeProvider.init();
  runApp(const MyParentsStoryApp());
}

class MyParentsStoryApp extends StatelessWidget {
  const MyParentsStoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final speechService = SpeechSetupService();
    final showSetup = !speechService.isSetupComplete;

    return ListenableBuilder(
      listenable: localeProvider,
      builder: (context, _) {
        return MaterialApp(
          title: "My Parents' Story",
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          locale: localeProvider.locale,
          supportedLocales: localeProvider.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: showSetup ? const SetupWizardScreen() : const LandingScreen(),
        );
      },
    );
  }
}
