import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/parent_profile.dart';
import '../models/memory.dart';
import 'storage_service.dart';
import 'google_drive_service.dart';

class BackupService {
  final StorageService _storage;
  final GoogleDriveService driveService;

  BackupService(this._storage, this.driveService);

  Future<String> exportToJson() async {
    final profiles = _storage.getAllProfiles();
    final Map<String, dynamic> data = {
      'version': '1.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'profiles': profiles.map((p) {
        final memories = _storage.getMemoriesForProfile(p.id);
        return {
          'profile': p.toMap(),
          'memories': memories.map((m) => m.toMap()).toList(),
        };
      }).toList(),
    };
    final jsonString = jsonEncode(data);

    // Automatically backup to Google Drive if signed in
    if (driveService.isSignedIn) {
      await driveService.backupData(jsonString);
    }

    return jsonString;
  }

  Future<bool> importFromJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      if (data['profiles'] == null) return false;

      for (final profileData in data['profiles']) {
        final profileMap = Map<String, dynamic>.from(profileData['profile']);
        final profile = ParentProfile.fromMap(profileMap);
        _storage.updateProfile(profile);

        if (profileData['memories'] != null) {
          for (final memoryData in profileData['memories']) {
            final memory =
                Memory.fromMap(Map<String, dynamic>.from(memoryData));
            _storage.saveMemory(
              profileId: memory.parentId,
              chapterId: memory.chapterId,
              questionId: memory.questionId,
              originalTranscript: memory.originalTranscript,
              originalRecording: memory.originalRecording,
              memoir: memory.memoir,
            );
          }
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> restoreFromDrive() async {
    if (!driveService.isSignedIn) return false;

    final jsonString = await driveService.restoreData();
    if (jsonString != null) {
      return await importFromJson(jsonString);
    }
    return false;
  }
}
