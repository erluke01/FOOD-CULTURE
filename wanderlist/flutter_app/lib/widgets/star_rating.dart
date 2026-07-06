import 'package:flutter/material.dart';
import '../theme.dart';

class StarDisplay extends StatelessWidget {
  final double score;
  final bool large;

  const StarDisplay({super.key, required this.score, this.large = false});

  @override
  Widget build(BuildContext context) {
    final full = score.floor();
    final half = (score - full) >= 0.25 && (score - full) < 0.75;
    final empty = 5 - full - (half ? 1 : 0);
    final starSize = large ? 16.0 : 13.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(full, (_) => Icon(Icons.star, size: starSize, color: AppTheme.terra)),
        if (half) Icon(Icons.star_half, size: starSize, color: AppTheme.terra),
        ...List.generate(empty, (_) => Icon(Icons.star_border, size: starSize, color: Colors.grey.shade300)),
        const SizedBox(width: 4),
        Text(
          score.toStringAsFixed(1),
          style: TextStyle(
            fontSize: large ? 14 : 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.terra,
          ),
        ),
      ],
    );
  }
}

/// Half-star selector using a horizontal row of tappable segments
class StarInput extends StatelessWidget {
  final double? value;
  final void Function(double?) onChange;

  const StarInput({super.key, required this.value, required this.onChange});

  static const _steps = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Clear button
        GestureDetector(
          onTap: value != null ? () => onChange(null) : null,
          child: Icon(Icons.clear, size: 16, color: value != null ? Colors.grey.shade400 : Colors.transparent),
        ),
        const SizedBox(width: 4),
        // 5 stars, each split in half (left = .5, right = 1.0)
        for (int s = 1; s <= 5; s++)
          SizedBox(
            width: 28,
            height: 28,
            child: Stack(
              children: [
                // Full star icon
                Icon(
                  value != null && value! >= s
                      ? Icons.star
                      : value != null && value! >= s - 0.5
                          ? Icons.star_half
                          : Icons.star_border,
                  size: 26,
                  color: (value != null && value! >= s - 0.5) ? AppTheme.terra : Colors.grey.shade300,
                ),
                // Left half tap (= s - 0.5)
                Positioned(
                  left: 0, top: 0, bottom: 0,
                  width: 14,
                  child: GestureDetector(
                    onTap: () => onChange(s - 0.5 == value ? null : s - 0.5),
                  ),
                ),
                // Right half tap (= s)
                Positioned(
                  right: 0, top: 0, bottom: 0,
                  width: 14,
                  child: GestureDetector(
                    onTap: () => onChange(s.toDouble() == value ? null : s.toDouble()),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
