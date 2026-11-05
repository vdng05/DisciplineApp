import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ProgressCard extends StatelessWidget {
  final int completedCount;
  final int totalCount;
  final double completionRate;

  const ProgressCard({
    super.key,
    required this.completedCount,
    required this.totalCount,
    required this.completionRate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Pick quote based on day of year
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final quoteIndex = dayOfYear % AppConstants.disciplineQuotes.length;
    final quoteItem = AppConstants.disciplineQuotes[quoteIndex];

    final isAllDone = totalCount > 0 && completedCount >= totalCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(18.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isAllDone
                ? [
                    const Color(0xFF10B981),
                    const Color(0xFF059669),
                  ]
                : isDark
                    ? [
                        const Color(0xFF312E81),
                        const Color(0xFF1E1B4B),
                      ]
                    : [
                        const Color(0xFF6366F1),
                        const Color(0xFF4F46E5),
                      ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: (isAllDone ? const Color(0xFF10B981) : AppColors.primary)
                  .withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title + Circular progress percent
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isAllDone
                                ? Icons.emoji_events_rounded
                                : Icons.military_tech_rounded,
                            color: Colors.amberAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isAllDone
                                ? 'Xuất sắc! Đạt 100%'
                                : 'Tiến độ hôm nay',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        totalCount == 0
                            ? 'Chưa có thói quen nào hôm nay'
                            : 'Đã hoàn thành $completedCount / $totalCount thói quen',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Percentage Badge / Circular indicator
                Container(
                  width: 54,
                  height: 54,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  child: Center(
                    child: Text(
                      '${completionRate.round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Linear Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: totalCount == 0 ? 0.0 : (completionRate / 100.0).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Motivational Quote
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.format_quote_rounded,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '"${quoteItem['quote']}" — ${quoteItem['author']}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 11.5,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
