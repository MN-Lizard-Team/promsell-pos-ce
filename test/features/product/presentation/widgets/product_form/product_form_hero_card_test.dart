import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/product_form_hero_card.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/stock_config.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

import '../../../../../helpers/mocks.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  late MockSettingsCubit settingsCubit;
  late TextEditingController nameCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController stockCtrl;
  late TextEditingController costCtrl;
  late TextEditingController barcodeCtrl;

  setUp(() {
    settingsCubit = MockSettingsCubit();
    when(() => settingsCubit.state).thenReturn(
      const SettingsState(
        status: SettingsStatus.loaded,
        settings: Settings(stockConfig: StockConfig(lowStockThreshold: 5)),
      ),
    );
    nameCtrl = TextEditingController(text: 'Coffee');
    priceCtrl = TextEditingController(text: '50');
    stockCtrl = TextEditingController(text: '10');
    costCtrl = TextEditingController(text: '30');
    barcodeCtrl = TextEditingController();
  });

  tearDown(() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    stockCtrl.dispose();
    costCtrl.dispose();
    barcodeCtrl.dispose();
  });

  Widget buildHero({void Function(int)? onGoToTab}) {
    return ProductFormHeroCard(
      imagePath: null,
      imageUrl: null,
      categoryName: 'Drinks',
      isLoading: false,
      onImageTap: () {},
      nameCtrl: nameCtrl,
      priceCtrl: priceCtrl,
      stockCtrl: stockCtrl,
      costCtrl: costCtrl,
      barcodeCtrl: barcodeCtrl,
      isActive: true,
      isRecommended: false,
      trackStock: true,
      currency: '฿',
      onGoToTab: onGoToTab ?? (_) {},
    );
  }

  testWidgets('shows name, price metric, and no-barcode chip', (tester) async {
    await tester.pumpApp(buildHero(), settingsCubit: settingsCubit);
    await tester.pumpAndSettle();

    expect(find.text('Coffee'), findsOneWidget);
    expect(find.textContaining('No barcode'), findsOneWidget);
    // MoneyText grouped
    expect(find.textContaining('50'), findsWidgets);
  });

  testWidgets('tapping no-barcode chip jumps to Codes tab index 3', (
    tester,
  ) async {
    int? tab;
    await tester.pumpApp(
      buildHero(onGoToTab: (i) => tab = i),
      settingsCubit: settingsCubit,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('No barcode'));
    await tester.pump();

    expect(tab, 3);
  });

  testWidgets('need-price chip jumps to Price tab', (tester) async {
    priceCtrl.text = '0';
    int? tab;
    await tester.pumpApp(
      buildHero(onGoToTab: (i) => tab = i),
      settingsCubit: settingsCubit,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Set price'));
    await tester.pump();

    expect(tab, 1);
  });
}
