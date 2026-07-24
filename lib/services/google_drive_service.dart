import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class GoogleDriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveAppdataScope,
    ],
  );

  GoogleSignInAccount? _currentUser;

  Future<bool> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      return _currentUser != null;
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
  }

  bool get isSignedIn => _currentUser != null;

  Future<drive.DriveApi?> _getDriveApi() async {
    final authClient = await _googleSignIn.authenticatedClient();
    if (authClient == null) return null;
    return drive.DriveApi(authClient);
  }

  Future<void> backupData(String jsonString) async {
    if (!isSignedIn) return;

    final api = await _getDriveApi();
    if (api == null) return;

    try {
      // Find existing backup file in appDataFolder
      final fileList = await api.files.list(
        spaces: 'appDataFolder',
        q: "name = 'myparentsstory_backup.json'",
      );

      final media = drive.Media(
        Stream.value(utf8.encode(jsonString)),
        utf8.encode(jsonString).length,
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        // Update existing
        final existingFileId = fileList.files!.first.id!;
        await api.files.update(
          drive.File(),
          existingFileId,
          uploadMedia: media,
        );
        debugPrint("Backup updated on Google Drive");
      } else {
        // Create new
        final newFile = drive.File()
          ..name = 'myparentsstory_backup.json'
          ..parents = ['appDataFolder'];
        await api.files.create(newFile, uploadMedia: media);
        debugPrint("Backup created on Google Drive");
      }
    } catch (e) {
      debugPrint("Google Drive Backup Error: $e");
    }
  }

  Future<String?> restoreData() async {
    if (!isSignedIn) return null;

    final api = await _getDriveApi();
    if (api == null) return null;

    try {
      final fileList = await api.files.list(
        spaces: 'appDataFolder',
        q: "name = 'myparentsstory_backup.json'",
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        final existingFileId = fileList.files!.first.id!;
        final response = await api.files.get(
          existingFileId,
          downloadOptions: drive.DownloadOptions.fullMedia,
        ) as drive.Media;

        final bytes =
            await response.stream.expand((element) => element).toList();
        return utf8.decode(bytes);
      }
      return null; // No backup found
    } catch (e) {
      debugPrint("Google Drive Restore Error: $e");
      return null;
    }
  }
}
