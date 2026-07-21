class AppConstants {
  AppConstants._();

  static const String appName = "My Parents' Story";
  static const String currentSchemaVersion = '1.0.0';
  static const String currentAppVersion = '0.1.0-alpha';

  static const int maxRecordingDurationMinutes = 10;
  static const int autosaveIntervalSeconds = 30;
  static const int maxBookVersions = 10;
  static const int searchMinQueryLength = 2;

  static const List<String> supportedLanguages = ['en', 'hi', 'gu', 'es'];
  static const String defaultLanguage = 'en';

  static const String exportFormatVersion = '1.0';
  static const String backupMagicHeader = 'MPS_BACKUP_V1';
}
