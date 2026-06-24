import 'package:flutter/material.dart';

class DailyCloseReadOnlyRow extends StatelessWidget {
  const DailyCloseReadOnlyRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          value,
        ],
      ),
    );
  }
}
