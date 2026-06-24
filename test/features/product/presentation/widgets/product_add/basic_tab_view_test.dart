import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_add/basic_tab_view.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('BasicTabView', () {
    late TextEditingController nameCtrl;
    late TextEditingController priceCtrl;
    late TextEditingController stockCtrl;

    setUp(() {
      nameCtrl = TextEditingController();
      priceCtrl = TextEditingController();
      stockCtrl = TextEditingController();
    });

    tearDown(() {
      nameCtrl.dispose();
      priceCtrl.dispose();
      stockCtrl.dispose();
    });

    testWidgets('renders text fields', (tester) async {
      await tester.pumpApp(
        BasicTabView(
          nameCtrl: nameCtrl,
          priceCtrl: priceCtrl,
          stockCtrl: stockCtrl,
          imagePath: null,
          isPickingImage: false,
          trackStock: true,
          selectedCategory: null,
          currency: '฿',
          onMarkDirty: () {},
          onImageTap: () {},
          onPickCategory: () {},
          onStockChanged: (v) {},
        ),
      );

      expect(find.byType(TextField), findsAtLeastNWidgets(2));
    });

    testWidgets('renders category when selected', (tester) async {
      final category = Category(
        id: 'c1',
        name: 'Drinks',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
      await tester.pumpApp(
        BasicTabView(
          nameCtrl: nameCtrl,
          priceCtrl: priceCtrl,
          stockCtrl: stockCtrl,
          imagePath: null,
          isPickingImage: false,
          trackStock: true,
          selectedCategory: category,
          currency: '฿',
          onMarkDirty: () {},
          onImageTap: () {},
          onPickCategory: () {},
          onStockChanged: (v) {},
        ),
      );

      expect(find.text('Drinks'), findsOneWidget);
    });
  });
}
