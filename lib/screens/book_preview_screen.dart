
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
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
  late final String _viewId;
  late final String _htmlContent;

  @override
  void initState() {
    super.initState();
    _viewId = 'book-preview-${widget.profile.id}-${DateTime.now().millisecondsSinceEpoch}';
    
    final service = LegacyComposerService();
    _htmlContent = service.generateHtmlBook(
      profile: widget.profile,
      chapters: widget.book.chapters,
      finalLetter: widget.book.finalLetter,
    );

    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final iframe = html.IFrameElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none'
        ..style.backgroundColor = '#FDFBF7'
        ..srcdoc = _htmlContent;
      return iframe;
    });
  }

  void _exportPdf() async {
    setState(() => _isExporting = true);

    try {
      final blob = html.Blob([_htmlContent], 'text/html');
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
        compact: (context) => _buildCompactLayout(context),
        medium: (context) => _buildExpandedLayout(context),
      ),
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: const Color(0xFFE5E5E5), // Background behind the book
            padding: const EdgeInsets.all(AppSpacing.m),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: HtmlElementView(viewType: _viewId),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        _buildExportButton(),
      ],
    );
  }

  Widget _buildExpandedLayout(BuildContext context) {
    return AdaptiveCenteredBox(
      maxWidth: 1400,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AdaptiveSpacing.horizontalPadding(context),
                vertical: AppSpacing.xl,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: HtmlElementView(viewType: _viewId),
                ),
              ),
            ),
          ),
          _buildExportButton(),
        ],
      ),
    );
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
