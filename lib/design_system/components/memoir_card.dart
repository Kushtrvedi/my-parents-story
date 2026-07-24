import 'package:flutter/material.dart';
import '../colors.dart';
import '../typography.dart';

class MemoirCard extends StatelessWidget {
  final String title;
  final String text;
  final String? parentName;
  final String? audioPath;
  final VoidCallback? onPlayAudio;

  const MemoirCard({
    super.key,
    required this.title,
    required this.text,
    this.parentName,
    this.audioPath,
    this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return const SizedBox.shrink();

    final firstChar = cleanText.substring(0, 1).toUpperCase();
    final remainingText = cleanText.length > 1 ? cleanText.substring(1) : '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.parchment,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.parchmentBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.amberGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.menu_book_rounded,
                        size: 14, color: AppColors.amberGold),
                    const SizedBox(width: 6),
                    Text(
                      'MEMOIR EXCERPT',
                      style: AppTypography.caption.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.amberGold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (onPlayAudio != null)
                IconButton(
                  icon: const Icon(Icons.play_circle_fill_rounded,
                      color: AppColors.primary, size: 32),
                  onPressed: onPlayAudio,
                  tooltip: 'Listen to Voice Memory',
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            title,
            style: AppTypography.heading.copyWith(
              fontSize: 20,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          // Published Book Excerpt Text with Drop Cap
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: firstChar,
                  style: AppTypography.display.copyWith(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    height: 0.9,
                  ),
                ),
                TextSpan(
                  text: remainingText,
                  style: AppTypography.body.copyWith(
                    fontSize: 18,
                    height: 1.6,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          if (parentName != null && parentName!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '— As remembered by $parentName',
                style: AppTypography.caption.copyWith(
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                  color: AppColors.textLight,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
