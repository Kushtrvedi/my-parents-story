import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/parent_profile.dart';
import '../models/response.dart';
import 'storage_service.dart';

class BackupService {
  final StorageService _storage;

  BackupService(this._storage);

  Future<String> exportToJson() async {
    final profiles = _storage.getAllProfiles();
    final Map<String, dynamic> data = {
      'version': '1.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'profiles': profiles.map((p) {
        final responses = _storage.getResponsesForProfile(p.id);
        return {
          'profile': p.toMap(),
          'responses': responses.map((r) => r.toMap()).toList(),
        };
      }).toList(),
    };
    return jsonEncode(data);
  }

  Future<File> saveExportToFile(String jsonData) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/my_parents_story_backup_$timestamp.json');
    await file.writeAsString(jsonData);
    return file;
  }

  Future<bool> importFromJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      if (data['profiles'] == null) return false;

      for (final profileData in data['profiles']) {
        final profileMap = Map<String, dynamic>.from(profileData['profile']);
        final profile = ParentProfile.fromMap(profileMap);
        _storage.updateProfile(profile);

        if (profileData['responses'] != null) {
          for (final responseData in profileData['responses']) {
            final response = StoryResponse.fromMap(Map<String, dynamic>.from(responseData));
            _storage.saveResponse(
              profileId: response.profileId,
              category: response.category,
              questionIndex: response.questionIndex,
              question: response.question,
              answer: response.answer,
            );
          }
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
