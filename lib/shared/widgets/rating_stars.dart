import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.rating, this.size = 14, this.reviewsCount});

  final double rating;
  final double size;
  final int? reviewsCount;

  @override
  Widget build(BuildContext context) {
    if (reviewsCount == 0) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          return Icon(
            i < rating.round() ? Icons.star : Icons.star_border,
            size: size,
            color: const Color(0xFFF5B301),
          );
        }),
        if (reviewsCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewsCount)',
            style: TextStyle(fontSize: size * 0.85, color: Colors.grey.shade600),
          ),
        ],
      ],
    );
  }
}
