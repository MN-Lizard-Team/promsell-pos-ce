import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/main.dart' as app;
import 'package:promsell_pos_ce/core/utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.info('Starting Promsell POS CE (dev flavor)');
  app.runPromsellApp();
}
