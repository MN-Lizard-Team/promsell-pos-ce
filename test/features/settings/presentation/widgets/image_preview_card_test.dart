import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/image_preview_card.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('ImagePreviewCard', () {
    testWidgets('renders with given width and quality', (tester) async {
      await tester.pumpApp(
        const ImagePreviewCard(imageMaxWidth: 800, imageQuality: 85),
      );

      expect(find.byType(ImagePreviewCard), findsOneWidget);
    });
  });
}
