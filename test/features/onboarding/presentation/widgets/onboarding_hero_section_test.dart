import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/onboarding_hero_section.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('OnboardingHeroSection', () {
    testWidgets('renders with subtitle', (tester) async {
      await tester.pumpApp(
        const OnboardingHeroSection(
          isDark: false,
          subtitle: 'Welcome to the app',
        ),
      );

      expect(find.byType(OnboardingHeroSection), findsOneWidget);
      expect(find.text('Welcome to the app'), findsOneWidget);
    });
  });
}
