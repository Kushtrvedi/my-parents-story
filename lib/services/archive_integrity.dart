import 'dart:convert';
import '../core/constants/app_constants.dart';
import '../core/errors/app_error.dart';
import '../core/result/result.dart';
import '../core/utils/utils.dart';

class ArchiveManifest {
  final String magic;
  final String version;
  final String schemaVersion;
  final String appVersion;
  final DateTime exportedAt;
  final String language;
  final String checksum;
  final int profileCount;
  final int memoryCount;
  final int chapterCount;

  const ArchiveManifest({
    required this.magic,
    required this.version,
    required this.schemaVersion,
    required this.appVersion,
    required this.exportedAt,
    required this.language,
    required this.checksum,
    required this.profileCount,
    required this.memoryCount,
    required this.chapterCount,
  });

  Map<String, dynamic> toMap() => {
    'magic': magic,
    'version': version,
    'schemaVersion': schemaVersion,
    'appVersion': appVersion,
    'exportedAt': exportedAt.toIso8601String(),
    'language': language,
    'checksum': checksum,
    'profileCount': profileCount,
    'memoryCount': memoryCount,
    'chapterCount': chapterCount,
  };

  factory ArchiveManifest.fromMap(Map<String, dynamic> map) => ArchiveManifest(
    magic: map['magic'] ?? '',
    version: map['version'] ?? '',
    schemaVersion: map['schemaVersion'] ?? '',
    appVersion: map['appVersion'] ?? '',
    exportedAt: map['exportedAt'] != null ? DateTime.parse(map['exportedAt']) : DateTime.now(),
    language: map['language'] ?? 'en',
    checksum: map['checksum'] ?? '',
    profileCount: map['profileCount'] ?? 0,
    memoryCount: map['memoryCount'] ?? 0,
    chapterCount: map['chapterCount'] ?? 0,
  );
}

class ArchiveIntegrityService {
  Result<ArchiveManifest> validateArchive(Map<String, dynamic> archive) {
    if (!archive.containsKey('manifest')) {
      return const Failure(AppError(code: 'NO_MANIFEST', message: 'Archive missing manifest'));
    }

    final manifest = ArchiveManifest.fromMap(Map<String, dynamic>.from(archive['manifest']));

    if (manifest.magic != AppConstants.backupMagicHeader) {
      return const Failure(AppError(code: 'INVALID_MAGIC', message: 'Invalid archive format'));
    }

    if (manifest.schemaVersion != AppConstants.currentSchemaVersion) {
      return Failure(AppError(
        code: 'SCHEMA_MISMATCH',
        message: 'Archive schema ${manifest.schemaVersion} differs from app schema ${AppConstants.currentSchemaVersion}',
      ));
    }

    final data = archive['data'];
    if (data == null) {
      return const Failure(AppError(code: 'NO_DATA', message: 'Archive contains no data'));
    }

    final dataString = jsonEncode(data);
    final calculatedChecksum = ChecksumCalculator.calculate(dataString);
    if (calculatedChecksum != manifest.checksum) {
      return const Failure(AppError(code: 'CHECKSUM_MISMATCH', message: 'Archive data has been modified or corrupted'));
    }

    return Success(manifest);
  }

  ArchiveManifest createManifest({
    required Map<String, dynamic> data,
    required int profileCount,
    required int memoryCount,
    required int chapterCount,
  }) {
    final dataString = jsonEncode(data);
    final checksum = ChecksumCalculator.calculate(dataString);

    return ArchiveManifest(
      magic: AppConstants.backupMagicHeader,
      version: AppConstants.exportFormatVersion,
      schemaVersion: AppConstants.currentSchemaVersion,
      appVersion: AppConstants.currentAppVersion,
      exportedAt: DateTime.now(),
      language: AppConstants.defaultLanguage,
      checksum: checksum,
      profileCount: profileCount,
      memoryCount: memoryCount,
      chapterCount: chapterCount,
    );
  }

  Map<String, dynamic> createArchive({
    required Map<String, dynamic> data,
    required int profileCount,
    required int memoryCount,
    required int chapterCount,
  }) {
    final manifest = createManifest(
      data: data,
      profileCount: profileCount,
      memoryCount: memoryCount,
      chapterCount: chapterCount,
    );

    return {
      'manifest': manifest.toMap(),
      'data': data,
    };
  }
}
