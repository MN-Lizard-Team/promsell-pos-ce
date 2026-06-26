import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/price_card.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  final product = Product(
    id: 'p1',
    name: 'Coffee',
    price: 80,
    cost: 50,
    stock: 10,
    isActive: true,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  group('PriceCard', () {
    testWidgets('renders selling price', (tester) async {
      await tester.pumpApp(PriceCard(product: product, currency: '฿'));

      expect(find.text('฿80.00'), findsOneWidget);
      expect(find.byIcon(Icons.sell_outlined), findsOneWidget);
    });

    testWidgets('renders profit and margin', (tester) async {
      await tester.pumpApp(PriceCard(product: product, currency: '฿'));

      expect(find.text('฿30.00'), findsOneWidget);
      expect(find.text('38%'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('renders loss with down trend icon', (tester) async {
      final lossProduct = product.copyWith(cost: 100.0);
      await tester.pumpApp(PriceCard(product: lossProduct, currency: '฿'));

      expect(find.text('฿-20.00'), findsOneWidget);
      expect(find.byIcon(Icons.trending_down), findsOneWidget);
    });

    testWidgets('renders zero margin when price is 0', (tester) async {
      final freeProduct = product.copyWith(price: 0);
      await tester.pumpApp(PriceCard(product: freeProduct, currency: '฿'));

      expect(find.text('0%'), findsOneWidget);
    });
  });

  group('PriceCard U6 fixes', () {
    testWidgets('selling price uses headlineSmall not headlineMedium (U6)', (
      tester,
    ) async {
      await tester.pumpApp(PriceCard(product: product, currency: '฿'));

      final moneyText = tester.widget(find.text('฿80.00'));
      expect(moneyText, isA<Text>());
      final text = moneyText as Text;
      expect(text.style?.fontSize, isNot(equals(28)));
    });
  });

  group('MiniStat', () {
    testWidgets('renders label and value', (tester) async {
      await tester.pumpApp(
        const MiniStat(
          label: 'Cost',
          value: Text('฿50'),
          icon: Icons.account_balance_wallet_outlined,
        ),
      );

      expect(find.text('Cost'), findsOneWidget);
      expect(find.text('฿50'), findsOneWidget);
    });
  });
}
