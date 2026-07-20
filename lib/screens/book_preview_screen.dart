import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../l10n/translations.dart';
import '../models/parent_profile.dart';
import '../models/generated_chapter.dart';
import '../services/pdf_export_service.dart';

class BookPreviewScreen extends StatefulWidget {
  final ParentProfile profile;
  final List<GeneratedChapter> chapters;
  final String finalLetter;

  const BookPreviewScreen({
    super.key,
    required this.profile,
    required this.chapters,
    required this.finalLetter,
  });

  @override
  State<BookPreviewScreen> createState() => _BookPreviewScreenState();
}

class _BookPreviewScreenState extends State<BookPreviewScreen> {
  final _pdfService = PdfExportService();
  bool _isGeneratingPdf = false;

  Future<void> _exportAndSharePdf() async {
    setState(() => _isGeneratingPdf = true);
    try {
      final file = await _pdfService.generateBook(
        profile: widget.profile,
        chapters: widget.chapters,
        finalLetter: widget.finalLetter,
      );
      if (mounted) await _pdfService.sharePdf(file);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${T.tr('error')}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(T.tr('preview'))),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCover(),
            _buildToc(),
            ...widget.chapters.map((c) => _buildChapterPreview(c)),
            _buildFinalLetter(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
              child: SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton.icon(
                  onPressed: _isGeneratingPdf ? null : _exportAndSharePdf,
                  icon: _isGeneratingPdf
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Icon(Icons.picture_as_pdf, size: 28),
                  label: Text(_isGeneratingPdf ? T.tr('generatingPdf') : T.tr('sharePdf')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      height: 480,
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 12))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accent),
            child: Center(
              child: Text(
                widget.profile.name.isNotEmpty ? widget.profile.name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 36),
          Text(
            widget.profile.name,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.primaryText),
          ),
          const SizedBox(height: 10),
          Text(
            T.tr('coverTitle'),
            style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: AppColors.secondaryText),
          ),
          if (widget.profile.birthYear.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('Born ${widget.profile.birthYear}', style: const TextStyle(fontSize: 16, color: AppColors.secondaryText)),
          ],
          if (widget.profile.city.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(widget.profile.city, style: const TextStyle(fontSize: 16, color: AppColors.secondaryText)),
          ],
          const SizedBox(height: 40),
          Container(
            width: 240,
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.accent), bottom: BorderSide(color: AppColors.accent)),
            ),
            child: const Text(
              '"Every parent deserves to leave behind their story."',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.secondaryText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToc() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(T.tr('toc'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Container(width: 48, height: 3, color: AppColors.accent),
          const SizedBox(height: 24),
          ...widget.chapters.asMap().entries.map((entry) {
            final ch = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Text('${ch.chapterNumber}', style: const TextStyle(fontSize: 16, color: AppColors.accent, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 14),
                  Expanded(child: Text(ch.title, style: const TextStyle(fontSize: 17, color: AppColors.primaryText))),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Text('${widget.chapters.length + 1}', style: const TextStyle(fontSize: 16, color: AppColors.accent, fontWeight: FontWeight.w700)),
                const SizedBox(width: 14),
                Expanded(child: Text(T.tr('finalLetter'), style: const TextStyle(fontSize: 17, fontStyle: FontStyle.italic, color: AppColors.primaryText))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterPreview(GeneratedChapter chapter) {
    final paragraphs = chapter.content.split('\n').where((p) => p.trim().isNotEmpty).take(3).toList();
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${T.tr('chapterN')} ${chapter.chapterNumber}', style: const TextStyle(fontSize: 13, color: AppColors.accent, letterSpacing: 2)),
          const SizedBox(height: 6),
          Text(chapter.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Container(width: 32, height: 3, color: AppColors.accent),
          const SizedBox(height: 20),
          ...paragraphs.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(p.trim(), style: const TextStyle(fontSize: 16, height: 1.7, color: Color(0xFF333333))),
              )),
          if (chapter.content.split('\n').where((p) => p.trim().isNotEmpty).length > 3)
            const Text('...', style: TextStyle(fontSize: 16, color: AppColors.secondaryText)),
        ],
      ),
    );
  }

  Widget _buildFinalLetter() {
    final paragraphs = widget.finalLetter.split('\n').where((p) => p.trim().isNotEmpty).take(5).toList();
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 32, height: 3, color: AppColors.accent)),
          const SizedBox(height: 18),
          Center(
            child: Text(T.tr('finalLetter'), style: const TextStyle(fontSize: 20, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 20),
          ...paragraphs.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(p.trim(), style: const TextStyle(fontSize: 16, height: 1.7, color: Color(0xFF333333))),
              )),
        ],
      ),
    );
  }
}
