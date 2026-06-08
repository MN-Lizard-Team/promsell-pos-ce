import 'package:flutter/material.dart';

class DailyCloseSummaryRow extends StatelessWidget {
  const DailyCloseSummaryRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), value],
      ),
    );
  }
}
