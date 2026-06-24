import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/demo_image_preview.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('DemoImagePreview', () {
    testWidgets('renders with width and quality', (tester) async {
      await tester.pumpApp(
        const DemoImagePreview(
          width: 800,
          quality: 85,
          st: SettingsThemeExtension.light,
        ),
      );

      expect(find.byType(DemoImagePreview), findsOneWidget);
    });
  });
}
