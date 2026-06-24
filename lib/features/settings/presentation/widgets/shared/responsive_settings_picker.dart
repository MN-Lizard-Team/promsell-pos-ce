import 'package:flutter/material.dart';

class ResponsiveSettingsPicker extends StatelessWidget {
  const ResponsiveSettingsPicker({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(icon),
                    const SizedBox(width: 16),
                    Expanded(child: Text(title)),
                  ],
                ),
                const SizedBox(height: 8),
                child,
              ],
            ),
          );
        }

        return ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: SizedBox(width: 180, child: child),
        );
      },
    );
  }
}
