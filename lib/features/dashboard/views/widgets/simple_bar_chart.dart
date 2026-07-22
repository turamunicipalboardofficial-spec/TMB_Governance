import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// A single bar in the chart.
class BarChartPoint {
  final String label;
  final double value;

  const BarChartPoint({required this.label, required this.value});
}

/// Minimal, dependency-free bar chart. Keeps the design language
/// consistent (no external chart package needed for simple trend views).
class SimpleBarChart extends StatelessWidget {
  final List<BarChartPoint> points;
  final Color color;
  final String Function(double value)? valueFormatter;
  final double height;

  const SimpleBarChart({
    super.key,
    required this.points,
    this.color = AppColors.primary,
    this.valueFormatter,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No data available',
            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
        ),
      );
    }

    final maxValue = points.map((p) => p.value).fold<double>(
          0,
          (prev, v) => v > prev ? v : prev,
        );
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: points.map((point) {
          final ratio = (point.value / safeMax).clamp(0.0, 1.0);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (point.value > 0)
                    Text(
                      valueFormatter?.call(point.value) ??
                          point.value.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  // The bar fills the remaining flexible space, scaled by
                  // ratio. Using Expanded+FractionallySizedBox avoids fixed
                  // pixel-offset math that can overflow with taller text.
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: ratio < 0.02 ? 0.02 : ratio,
                        widthFactor: 1,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: point.value > 0
                                ? color
                                : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    point.label,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
