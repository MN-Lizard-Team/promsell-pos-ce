import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_detail_row.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('CartDetailRow', () {
    testWidgets('renders label and value text', (tester) async {
      await tester.pumpApp(const CartDetailRow('Subtotal', 'THB100'));

      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('THB100'), findsOneWidget);
    });
  });
}
