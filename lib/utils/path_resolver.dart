import 'package:path_provider/path_provider.dart';

class PathResolver {
  /// Ensures the string is stored as a relative path.
  /// If it's already an absolute path within the app's document directory, it strips the base.
  static Future<String> toRelative(String absoluteOrRelativePath) async {
    if (!absoluteOrRelativePath.startsWith('/')) {
      return absoluteOrRelativePath; // Already relative
    }
    
    final docDir = await getApplicationDocumentsDirectory();
    if (absoluteOrRelativePath.startsWith(docDir.path)) {
      return absoluteOrRelativePath.replaceFirst('${docDir.path}/', '');
    }
    
    // Fallback if the path is outside expected directories (e.g., from a picker).
    // In a real app, we would copy the file into our managed directory first.
    // For this implementation, we just return the basename if it's external,
    // assuming the file was already copied.
    return absoluteOrRelativePath.split('/').last;
  }

  /// Resolves a relative path to an absolute path for reading/playback.
  static Future<String> toAbsolute(String relativePath) async {
    if (relativePath.startsWith('/')) {
      return relativePath; // Already absolute (legacy data or external)
    }
    final docDir = await getApplicationDocumentsDirectory();
    return '${docDir.path}/$relativePath';
  }
}
