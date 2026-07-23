import '../models/parent_profile.dart';
import '../models/generated_chapter.dart';
import '../themes/heritage_linen_theme.dart';

class LegacyComposerService {
  String generateHtmlBook({
    required ParentProfile profile,
    required List<GeneratedChapter> chapters,
    required String finalLetter,
  }) {
    final buffer = StringBuffer();

    // HTML Header & Paged.js Configuration
    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html lang="en">');
    buffer.writeln('<head>');
    buffer.writeln('<meta charset="UTF-8">');
    buffer.writeln('<title>${profile.name} - Legacy Book</title>');
    
    // Inject Paged.js config to auto-print when pagination completes
    buffer.writeln('''
      <script>
        window.PagedConfig = { auto: true };
        document.addEventListener('DOMContentLoaded', () => {
          // You could auto-print here, but it's better to let them preview the paginated book first.
          // Or add a custom print button.
        });
      </script>
    ''');
    
    // Inject Paged.js
    buffer.writeln('<script src="https://unpkg.com/pagedjs/dist/paged.polyfill.js"></script>');
    
    // Inject Heritage Linen CSS
    buffer.writeln('<style>${HeritageLinenTheme.css}</style>');
    
    buffer.writeln('</head>');
    buffer.writeln('<body>');

    // 1. Cover Page
    buffer.writeln('<div class="cover-page">');
    buffer.writeln('<div class="cover-title">MY PARENTS\' STORY</div>');
    buffer.writeln('<div class="cover-subtitle">The Life of<br><br>${profile.name}<br><br>${profile.birthYear.isNotEmpty ? "${profile.birthYear} — Present" : ""}</div>');
    buffer.writeln('<div class="cover-author">Collected with love by<br>The Family</div>');
    buffer.writeln('</div>'); // End Cover

    // 2. Chapters
    for (int i = 0; i < chapters.length; i++) {
      final chapter = chapters[i];
      if (chapter.content.trim().isEmpty) continue;

      buffer.writeln('<div class="chapter">');
      
      buffer.writeln('<div class="chapter-header">');
      buffer.writeln('<div class="chapter-number">CHAPTER ${i + 1}</div>');
      buffer.writeln('<h2 class="chapter-title">${chapter.title}</h2>');
      buffer.writeln('</div>');

      buffer.writeln('<div class="chapter-quote">"The story begins here..."</div>'); // Placeholder for specific extraction
      
      buffer.writeln('<div class="content-body">');
      // Simple split by double newline for paragraphs
      final paragraphs = chapter.content.split('\\n\\n');
      for (final p in paragraphs) {
        if (p.trim().isNotEmpty) {
          buffer.writeln('<p>${p.trim()}</p>');
        }
      }
      buffer.writeln('</div>');

      // Voice Memory QR Code Placeholder
      buffer.writeln('<div class="voice-memory">');
      buffer.writeln('<p>🎤 Listen to this memory</p>');
      // Using a dummy QR code from an API for visual representation
      buffer.writeln('<img src="https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=example" alt="QR Code" />');
      buffer.writeln('</div>');

      buffer.writeln('</div>'); // End Chapter
    }

    // 3. Final Letter / Legacy Page
    buffer.writeln('<div class="chapter">');
    buffer.writeln('<div class="chapter-header">');
    buffer.writeln('<h2 class="chapter-title">What I Hope My Family Remembers</h2>');
    buffer.writeln('</div>');
    buffer.writeln('<div class="content-body">');
    final letterParagraphs = finalLetter.split('\\n\\n');
    for (final p in letterParagraphs) {
      if (p.trim().isNotEmpty) {
        buffer.writeln('<p>${p.trim()}</p>');
      }
    }
    buffer.writeln('<br><br><p><i>With love,<br>${profile.name}</i></p>');
    buffer.writeln('</div>');
    buffer.writeln('</div>');

    // 4. Acknowledgements / Ending Page
    buffer.writeln('<div class="final-page">');
    buffer.writeln('<p>This book preserves one life.</p>');
    buffer.writeln('<p>May it inspire many more conversations.</p>');
    buffer.writeln('<div class="platform-credit">Recorded using My Parents\' Story.</div>');
    buffer.writeln('</div>');

    buffer.writeln('</body>');
    buffer.writeln('</html>');

    return buffer.toString();
  }
}
