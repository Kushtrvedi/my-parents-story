import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../config/app_theme.dart';
import '../design_system/design_system.dart';
import '../l10n/translations.dart';
import '../models/generated_chapter.dart';
import '../models/parent_profile.dart';
import '../services/pdf_export_service.dart';

class BookPreviewScreen extends StatefulWidget {
  final ParentProfile profile;
  final GeneratedBook book;
  const BookPreviewScreen({super.key, required this.profile, required this.book});

  @override
  State<BookPreviewScreen> createState() => _BookPreviewScreenState();
}

class _BookPreviewScreenState extends State<BookPreviewScreen> {
  bool _isExporting = false;

  void _exportPdf() async {
    setState(() => _isExporting = true);

    try {
      final service = PdfExportService();
      final file = await service.generateBook(
        profile: widget.profile,
        chapters: widget.book.chapters,
        finalLetter: widget.book.finalLetter,
      );

      if (!mounted) return;
      await Share.shareXFiles([XFile(file.path)], text: T.tr('sharePdf'));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(T.tr('errorOccurred'))),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chapters = widget.book.chapters;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('${widget.profile.name}\'s ${T.tr('bookPreview')}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              children: [
                // Cover
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(36),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${widget.profile.name}\'s',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontSize: 32,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        T.tr('storyTitle'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 44,
                            ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: 48,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        T.tr('memoirOf'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                      ),
                      if (widget.profile.birthYear != null && widget.profile.birthYear!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          T.tr('bornYear').replaceAll('{year}', widget.profile.birthYear!),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Chapter list
                ...chapters.map((chapter) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${chapter.chapterNumber}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.primary,
                              ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chapter.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                T.tr('storiesHere'),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Export button
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
            child: SizedBox(
              width: double.infinity,
              height: 76,
              child: ElevatedButton.icon(
                onPressed: _isExporting ? null : _exportPdf,
                icon: _isExporting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.download_outlined, size: 24),
                label: Text(_isExporting ? T.tr('generatingBook') : T.tr('exportPdf')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
