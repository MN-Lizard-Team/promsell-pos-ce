import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/testing/test_keys.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

enum HomeMenuItem { sell, products, customers, promotions, history, closeDay }

class HomeMenuGrid extends StatelessWidget {
  const HomeMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final items = [
      _MenuItem(
        icon: TablerIcons.buildingStore,
        label: l10n.navSale,
        iconColor: cs.primary,
        item: HomeMenuItem.sell,
      ),
      _MenuItem(
        icon: TablerIcons.cube,
        label: l10n.navProducts,
        iconColor: cs.secondary,
        item: HomeMenuItem.products,
      ),
      _MenuItem(
        icon: TablerIcons.addressBook,
        label: l10n.customersTitle,
        iconColor: cs.tertiary,
        item: HomeMenuItem.customers,
      ),
      _MenuItem(
        icon: Icons.local_offer_outlined,
        label: l10n.promotionsTitle,
        iconColor: cs.error,
        item: HomeMenuItem.promotions,
      ),
      _MenuItem(
        icon: TablerIcons.receipt2,
        label: l10n.homeHistory,
        iconColor: cs.secondary,
        item: HomeMenuItem.history,
      ),
      _MenuItem(
        icon: Icons.task_alt,
        label: l10n.homeCloseDay,
        iconColor: cs.primary,
        item: HomeMenuItem.closeDay,
        tileKey: const Key(TestKeys.homeCloseDayTile),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.homeMainMenu,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 8),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (context, i) {
              final item = items[i];
              return _MenuButton(item: item, tileKey: item.tileKey);
            },
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.item,
    this.tileKey,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final HomeMenuItem item;

  /// Optional stable E2E anchor for the tile's InkWell (test-only, additive).
  final Key? tileKey;
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.item, this.tileKey});
  final _MenuItem item;

  /// Stable E2E anchor surfaced from [_MenuItem.tileKey].
  final Key? tileKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shadowColor: cs.shadow.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        key: tileKey,
        onTap: () => _onTap(context),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.iconColor.withValues(alpha: 0.12),
                ),
                child: Icon(item.icon, size: 28, color: item.iconColor),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    final handler = HomeMenuGridTapHandler.of(context);
    handler?.onTap(item.item);
  }
}

typedef HomeMenuTapCallback = void Function(HomeMenuItem item);

class HomeMenuGridTapHandler extends InheritedWidget {
  const HomeMenuGridTapHandler({
    super.key,
    required this.onTap,
    required super.child,
  });

  final HomeMenuTapCallback onTap;

  static HomeMenuGridTapHandler? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HomeMenuGridTapHandler>();
  }

  @override
  bool updateShouldNotify(HomeMenuGridTapHandler oldWidget) =>
      onTap != oldWidget.onTap;
}
