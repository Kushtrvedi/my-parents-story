import '../errors/app_error.dart';
import '../result/result.dart';

class Validators {
  Validators._();

  static Result<String> validateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const Failure(ValidationError(field: 'name', message: 'Name cannot be empty'));
    }
    if (trimmed.length < 2) {
      return const Failure(ValidationError(field: 'name', message: 'Name must be at least 2 characters'));
    }
    if (trimmed.length > 100) {
      return const Failure(ValidationError(field: 'name', message: 'Name must be less than 100 characters'));
    }
    return Success(trimmed);
  }

  static Result<String> validateBirthYear(String year) {
    final trimmed = year.trim();
    if (trimmed.isEmpty) return const Success('');
    final parsed = int.tryParse(trimmed);
    if (parsed == null) {
      return const Failure(ValidationError(field: 'birthYear', message: 'Please enter a valid year'));
    }
    if (parsed < 1900 || parsed > DateTime.now().year) {
      return const Failure(ValidationError(field: 'birthYear', message: 'Year must be between 1900 and now'));
    }
    return Success(trimmed);
  }

  static Result<String> validateCity(String city) {
    final trimmed = city.trim();
    if (trimmed.isEmpty) return const Success('');
    if (trimmed.length > 100) {
      return const Failure(ValidationError(field: 'city', message: 'City name too long'));
    }
    return Success(trimmed);
  }

  static Result<String> validateResponse(String response) {
    final trimmed = response.trim();
    if (trimmed.isEmpty) {
      return const Failure(ValidationError(field: 'response', message: 'Please share your memory'));
    }
    if (trimmed.length > 50000) {
      return const Failure(ValidationError(field: 'response', message: 'Response is too long'));
    }
    return Success(trimmed);
  }

  static Result<String> validateBackupData(Map<String, dynamic> data) {
    if (data.isEmpty) {
      return const Failure(AppError(code: 'EMPTY_BACKUP', message: 'Backup file is empty'));
    }
    if (!data.containsKey('profiles') || !data.containsKey('responses')) {
      return const Failure(AppError(code: 'INVALID_BACKUP', message: 'Backup is missing required fields'));
    }
    return const Success('valid');
  }
}
