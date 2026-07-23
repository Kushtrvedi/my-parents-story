import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class PathResolver {
  static Future<String> toAbsolute(String relativePath) async {
    if (kIsWeb) {
      return relativePath;
    }
    if (relativePath.startsWith('/')) {
      return relativePath;
    }
    final docDir = await getApplicationDocumentsDirectory();
    return '${docDir.path}/$relativePath';
  }
}
