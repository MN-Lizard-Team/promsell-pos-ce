import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/home/presentation/widgets/home_promotion_banner.dart';
import 'package:promsell_pos_ce/features/promotion/domain/entities/promotion.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('HomePromotionBanner', () {
    testWidgets('shows create promotion CTA when no active promotion', (
      tester,
    ) async {
      await tester.pumpApp(HomePromotionBanner(promotion: null, onTap: () {}));

      expect(find.text('Create Promotion'), findsOneWidget);
    });

    testWidgets('shows promotion name when active promotion exists', (
      tester,
    ) async {
      final now = DateTime.now();
      final promo = Promotion(
        id: 'p1',
        name: 'Summer Sale',
        type: PromotionType.percent,
        value: 20,
        startDate: now.subtract(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 30)),
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpApp(HomePromotionBanner(promotion: promo, onTap: () {}));

      expect(find.text('Summer Sale'), findsOneWidget);
    });

    testWidgets('calls onTap when banner is tapped', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        HomePromotionBanner(promotion: null, onTap: () => tapped = true),
      );

      await tester.tap(find.byType(HomePromotionBanner));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('has button semantics for screen readers', (tester) async {
      await tester.pumpApp(HomePromotionBanner(promotion: null, onTap: () {}));

      final semantics = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.button == true,
      );
      expect(semantics, findsOneWidget);
    });
  });
}
