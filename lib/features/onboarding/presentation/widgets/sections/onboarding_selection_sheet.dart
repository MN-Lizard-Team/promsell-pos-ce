import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_sheet_option.dart';

class OnboardingSelectionOption<T> {
  const OnboardingSelectionOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
  });

  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
}

class OnboardingSelectionField<T> extends StatelessWidget {
  const OnboardingSelectionField({
    super.key,
    required this.label,
    required this.valueLabel,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String valueLabel;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label: $valueLabel',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(icon, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          valueLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.expand_more),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingSelectionSheet {
  OnboardingSelectionSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required T selected,
    required List<OnboardingSelectionOption<T>> options,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...options.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OnboardingSheetOption(
                    icon: option.icon ?? Icons.check,
                    label: option.label,
                    subtitle: option.subtitle,
                    selected: option.value == selected,
                    accentColor: theme.colorScheme.primary,
                    isDark: theme.brightness == Brightness.dark,
                    onTap: () => Navigator.of(sheetContext).pop(option.value),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
