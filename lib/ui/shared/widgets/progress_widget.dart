import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/theme/app_colors.dart';

class TranslationProgressWidget extends StatelessWidget {
  final double progress;
  final String title;
  final String? subtitle;
  final String? timeRemaining;
  final String? wordsTranslated;

  const TranslationProgressWidget({
    super.key,
    required this.progress,
    required this.title,
    this.subtitle,
    this.timeRemaining,
    this.wordsTranslated,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            const SizedBox(height: 16),
            LinearPercentIndicator(
              percent: progress.clamp(0.0, 1.0),
              progressColor: AppColors.translationProgress,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              barRadius: const Radius.circular(8),
              padding: EdgeInsets.zero,
              animation: true,
              lineHeight: 12,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (wordsTranslated != null)
                  Text(
                    wordsTranslated!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                if (timeRemaining != null)
                  Text(
                    timeRemaining!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
