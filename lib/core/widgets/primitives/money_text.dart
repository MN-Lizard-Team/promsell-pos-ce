import 'package:flutter/material.dart';

class MoneyText extends StatelessWidget {
  const MoneyText({
    super.key,
    required this.value,
    required this.currency,
    this.style,
    this.color,
    this.textAlign,
  });

  final double value;
  final String currency;
  final TextStyle? style;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? Theme.of(context).textTheme.titleMedium;

    return Text(
      '$currency${value.toStringAsFixed(2)}',
      textAlign: textAlign,
      style: effectiveStyle?.copyWith(
        color: color ?? effectiveStyle.color,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
