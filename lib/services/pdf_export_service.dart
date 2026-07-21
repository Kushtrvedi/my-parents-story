import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/parent_profile.dart';
import '../models/generated_chapter.dart';
import '../l10n/translations.dart';

class PdfExportService {
  Future<File> generateBook({
    required ParentProfile profile,
    required List<GeneratedChapter> chapters,
    required String finalLetter,
    String? originalLanguage,
    String? generatedLanguage,
  }) async {
    final pdf = pw.Document(
      title: '${profile.name} Memoir',
      author: profile.name,
      creator: "My Parents' Story",
      subject: 'Language: ${generatedLanguage ?? 'Unknown'} (Original: ${originalLanguage ?? 'Unknown'})',
    );

    pdf.addPage(_buildCoverPage(profile));
    pdf.addPage(_buildTableOfContentsPage(chapters));

    for (final chapter in chapters) {
      if (chapter.content.trim().isNotEmpty) {
        pdf.addPage(_buildChapterPage(chapter));
      }
    }

    pdf.addPage(_buildFinalLetterPage(finalLetter, profile.name));

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${profile.name}_memoir.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Page _buildCoverPage(ParentProfile profile) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.FullPage(
          ignoreMargins: true,
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.SizedBox(height: 80),
              pw.Container(
                width: 120,
                height: 120,
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  color: PdfColor.fromHex('#C9A96E'),
                ),
                child: pw.Center(
                  child: pw.Text(
                    profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                    style: const pw.TextStyle(
                      fontSize: 48,
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 40),
              pw.Text(
                profile.name,
                style: pw.TextStyle(
                  fontSize: 36,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#111111'),
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                T.tr('aLifeStory'),
                style: pw.TextStyle(
                  fontSize: 18,
                  color: PdfColor.fromHex('#666666'),
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              if (profile.birthYear.isNotEmpty) ...[
                pw.SizedBox(height: 8),
                pw.Text(
                  T.tr('bornYear').replaceAll('{year}', profile.birthYear),
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColor.fromHex('#666666'),
                  ),
                ),
              ],
              if (profile.city.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text(
                  profile.city,
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColor.fromHex('#666666'),
                  ),
                ),
              ],
              pw.SizedBox(height: 60),
              pw.Container(
                width: 300,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(color: PdfColor.fromHex('#C9A96E')),
                    bottom: pw.BorderSide(color: PdfColor.fromHex('#C9A96E')),
                  ),
                ),
                child: pw.Text(
                  T.tr('everyParentDeserves'),
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColor.fromHex('#666666'),
                  ),
                ),
              ),
              pw.SizedBox(height: 40),
              pw.Text(
                T.tr('myParentsStory'),
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColor.fromHex('#C9A96E'),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  pw.Page _buildTableOfContentsPage(List<GeneratedChapter> chapters) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 60, vertical: 80),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                T.tr('tableOfContents'),
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#111111'),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Container(width: 60, height: 2, color: PdfColor.fromHex('#C9A96E')),
              pw.SizedBox(height: 40),
              ...chapters.asMap().entries.map((entry) {
                final chapter = entry.value;
                return pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColor.fromHex('#E8E8E8'), width: 0.5),
                    ),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Text(
                        '${chapter.chapterNumber}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColor.fromHex('#C9A96E'),
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(width: 16),
                      pw.Expanded(
                        child: pw.Text(
                          chapter.title,
                          style: pw.TextStyle(
                            fontSize: 16,
                            color: PdfColor.fromHex('#111111'),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 12),
                child: pw.Row(
                  children: [
                    pw.Text(
                      '${chapters.length + 1}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColor.fromHex('#C9A96E'),
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(width: 16),
                    pw.Expanded(
                      child: pw.Text(
                        T.tr('finalLetterTitle'),
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: PdfColor.fromHex('#111111'),
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  pw.Page _buildChapterPage(GeneratedChapter chapter) {
    final paragraphs = chapter.content
        .split('\n')
        .where((p) => p.trim().isNotEmpty && !p.startsWith('#'))
        .toList();

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 60, vertical: 80),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '${T.tr("chapterPrefix")}${chapter.chapterNumber}',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColor.fromHex('#C9A96E'),
                  letterSpacing: 2,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                chapter.title,
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#111111'),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Container(width: 40, height: 2, color: PdfColor.fromHex('#C9A96E')),
              pw.SizedBox(height: 30),
              ...paragraphs.map((p) {
                return pw.Paragraph(
                  text: p.trim(),
                  style: pw.TextStyle(
                    fontSize: 12,
                    lineSpacing: 18,
                    color: PdfColor.fromHex('#333333'),
                  ),
                  margin: const pw.EdgeInsets.only(bottom: 12),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  pw.Page _buildFinalLetterPage(String letter, String parentName) {
    final paragraphs = letter
        .split('\n')
        .where((p) => p.trim().isNotEmpty && !p.startsWith('#'))
        .toList();

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 60, vertical: 80),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 40),
              pw.Center(
                child: pw.Container(width: 40, height: 2, color: PdfColor.fromHex('#C9A96E')),
              ),
              pw.SizedBox(height: 30),
              pw.Center(
                child: pw.Text(
                  T.tr('whatIHope'),
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColor.fromHex('#111111'),
                  ),
                ),
              ),
              pw.SizedBox(height: 30),
              ...paragraphs.map((p) {
                return pw.Paragraph(
                  text: p.trim(),
                  style: pw.TextStyle(
                    fontSize: 12,
                    lineSpacing: 18,
                    color: PdfColor.fromHex('#333333'),
                  ),
                  margin: const pw.EdgeInsets.only(bottom: 12),
                );
              }),
              pw.SizedBox(height: 40),
              pw.Center(
                child: pw.Text(
                  T.tr('withLove').replaceAll('{name}', parentName),
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColor.fromHex('#666666'),
                  ),
                ),
              ),
              pw.SizedBox(height: 60),
              pw.Center(
                child: pw.Text(
                  T.tr('myParentsStory'),
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColor.fromHex('#C9A96E'),
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
