import 'package:integration_test/integration_test.dart';

import 'day_close_journey_test.dart' as day_close;
import 'sale_happy_path_test.dart' as sale_happy_path;
import 'restaurant_order_test.dart' as restaurant_order;
import 'draft_recovery_test.dart' as draft_recovery;
import 'product_management_test.dart' as product_management;
import 'promotion_application_test.dart' as promotion_application;

/// Integration test entry point
/// Runs all E2E critical user journey tests
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Journey 1: Happy Path Sale (Retail Mode)
  sale_happy_path.main();

  // Journey 2: Restaurant Order Flow
  restaurant_order.main();

  // Journey 3: Draft Cart Recovery
  draft_recovery.main();

  // Journey 4: Product Management
  product_management.main();

  // Journey 5: Promotion Application
  promotion_application.main();
  // Journey 6: Mixed tender -> void -> day-close reconciliation
  day_close.main();
}
