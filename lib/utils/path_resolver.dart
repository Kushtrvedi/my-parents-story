import 'package:path_provider/path_provider.dart';

class PathResolver {
  static Future<String> toAbsolute(String relativePath) async {
    if (relativePath.startsWith('/')) {
      return relativePath;
    }
    final docDir = await getApplicationDocumentsDirectory();
    return '${docDir.path}/$relativePath';
  }
}
