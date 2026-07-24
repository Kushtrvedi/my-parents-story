class AppError {
  final String code;
  final String message;
  final String? details;
  final Object? cause;

  const AppError({
    required this.code,
    required this.message,
    this.details,
    this.cause,
  });

  @override
  String toString() =>
      'AppError($code): $message${details != null ? ' - $details' : ''}';

  static const storageError = AppError(
      code: 'STORAGE_ERROR', message: 'Failed to access local storage');
  static const profileNotFound =
      AppError(code: 'PROFILE_NOT_FOUND', message: 'Profile not found');
  static const memoryNotFound =
      AppError(code: 'MEMORY_NOT_FOUND', message: 'Memory not found');
  static const invalidBackup = AppError(
      code: 'INVALID_BACKUP', message: 'Backup file is invalid or corrupted');
  static const schemaMismatch = AppError(
      code: 'SCHEMA_MISMATCH',
      message: 'Backup schema version is incompatible');
  static const checksumMismatch = AppError(
      code: 'CHECKSUM_MISMATCH', message: 'Backup integrity check failed');
  static const voiceUnavailable = AppError(
      code: 'VOICE_UNAVAILABLE', message: 'Voice recording is not available');
  static const exportFailed =
      AppError(code: 'EXPORT_FAILED', message: 'Failed to export data');
  static const importFailed =
      AppError(code: 'IMPORT_FAILED', message: 'Failed to import data');
}

class ValidationError extends AppError {
  final String field;

  const ValidationError({required this.field, required super.message})
      : super(code: 'VALIDATION_$field');
}
