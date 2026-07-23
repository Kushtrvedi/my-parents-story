
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'dart:html' as html;
import '../design_system/design_system.dart';
import '../l10n/translations.dart';
import '../models/generated_chapter.dart';
import '../models/parent_profile.dart';
import '../services/legacy_composer_service.dart';

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
      final service = LegacyComposerService();
      final htmlContent = service.generateHtmlBook(
        profile: widget.profile,
        chapters: widget.book.chapters,
        finalLetter: widget.book.finalLetter,
      );

      final blob = html.Blob([htmlContent], 'text/html');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.window.open(url, '_blank');
      // Intentionally not revoking the URL immediately so the tab can load it.
      
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
      body: ResponsiveBuilder(
        compact: (context) => _buildCompactLayout(context, chapters),
        medium: (context) => _buildExpandedLayout(context, chapters),
      ),
    );
  }

  Widget _buildCompactLayout(BuildContext context, List<GeneratedChapter> chapters) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.l),
            children: [
              _buildCover(context),
              const SizedBox(height: AppSpacing.xl),
              ..._buildChapterList(context, chapters),
            ],
          ),
        ),
        _buildExportButton(),
      ],
    );
  }

  Widget _buildExpandedLayout(BuildContext context, List<GeneratedChapter> chapters) {
    return AdaptiveCenteredBox(
      maxWidth: 1200,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AdaptiveSpacing.horizontalPadding(context),
                vertical: AppSpacing.xl,
              ),
              child: TwoColumnLayout(
                spacing: 48,
                leftChild: SingleChildScrollView(
                  child: _buildCover(context),
                ),
                rightChild: ListView(
                  children: [
                    Text(
                      T.tr('tableOfContents'),
                      style: AppTypography.heading,
                    ),
                    const SizedBox(height: AppSpacing.l),
                    ..._buildChapterList(context, chapters),
                  ],
                ),
              ),
            ),
          ),
          _buildExportButton(),
        ],
      ),
    );
  }

  Widget _buildCover(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 30,
            offset: Offset(0, 12),
          ),
        ],
        border: Border.all(color: AppColors.amberGold.withValues(alpha: 0.5), width: 2),
      ),
      child: Column(
        children: [
          const Icon(Icons.workspace_premium_rounded, color: AppColors.amberGold, size: 40),
          const SizedBox(height: 16),
          Text(
            '${widget.profile.name}\'s',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.amberGold,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            T.tr('storyTitle'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 40,
                ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 60,
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.amberGold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            T.tr('memoirOf'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontStyle: FontStyle.italic,
                ),
          ),
          if (widget.profile.birthYear.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              T.tr('bornYear').replaceAll('{year}', widget.profile.birthYear),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.amberGold.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildChapterList(BuildContext context, List<GeneratedChapter> chapters) {
    return chapters.map((chapter) {
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
    }).toList();
  }

  Widget _buildExportButton() {
    return Padding(
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
          );
  }
}
