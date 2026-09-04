import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PriceTag extends StatelessWidget {
  const PriceTag({
    super.key,
    required this.amount,
    required this.currencySymbol,
    this.suffix,
    this.size = 16,
    this.color,
  });

  final num amount;
  final String currencySymbol;
  final String? suffix;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat.decimalPattern().format(amount);
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w700,
          color: color ?? Theme.of(context).colorScheme.onSurface,
        ),
        children: [
          TextSpan(text: '$currencySymbol $formatted'),
          if (suffix != null)
            TextSpan(
              text: ' $suffix',
              style: TextStyle(fontSize: size * 0.7, fontWeight: FontWeight.normal, color: Colors.grey.shade600),
            ),
        ],
      ),
    );
  }
}
