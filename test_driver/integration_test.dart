import 'package:flutter_driver/driver_extension.dart';
import 'package:promsell_pos_ce/main_dev.dart' as app;

/// Test driver for integration tests
void main() {
  enableFlutterDriverExtension();
  app.main();
}
