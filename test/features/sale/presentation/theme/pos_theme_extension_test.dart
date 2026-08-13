import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';

void main() {
  test('light and dark constants differ on catalog background', () {
    expect(
      PosThemeExtension.light.catalogBackground,
      isNot(PosThemeExtension.dark.catalogBackground),
    );
    expect(PosThemeExtension.light.ctaFill, PosThemeExtension.dark.ctaFill);
  });

  test('copyWith overrides selected fields', () {
    final next = PosThemeExtension.light.copyWith(
      ctaMinHeight: 60,
      dockedCartWidth: 400,
      catalogBackground: Colors.red,
      billStubRadius: 16,
      activeBillRail: Colors.blue,
    );
    expect(next.ctaMinHeight, 60);
    expect(next.dockedCartWidth, 400);
    expect(next.catalogBackground, Colors.red);
    expect(next.billStubRadius, 16);
    expect(next.activeBillRail, Colors.blue);
    expect(next.productCardRadius, PosThemeExtension.light.productCardRadius);
    expect(next.parkCtaForeground, PosThemeExtension.light.parkCtaForeground);
  });

  test('multi-bill tokens differ light vs dark paper', () {
    expect(
      PosThemeExtension.light.billStubPaper,
      isNot(PosThemeExtension.dark.billStubPaper),
    );
    expect(PosThemeExtension.light.ctaFill, PosThemeExtension.dark.ctaFill);
  });

  test('lerp midway blends colors and doubles', () {
    final mid = PosThemeExtension.light.lerp(PosThemeExtension.dark, 0.5);
    expect(mid, isA<PosThemeExtension>());
    expect(
      mid.productCardRadius,
      closeTo(PosThemeExtension.light.productCardRadius, 0.01),
    );
    // catalog background should not equal either extreme when t=0.5
    expect(
      mid.catalogBackground,
      isNot(PosThemeExtension.light.catalogBackground),
    );
    expect(
      mid.catalogBackground,
      isNot(PosThemeExtension.dark.catalogBackground),
    );
  });

  test('lerp with null/other type returns this', () {
    final light = PosThemeExtension.light;
    expect(identical(light.lerp(null, 0.3), light), isTrue);
  });

  test('elevation ladder is ordered and capped at modal/fab active', () {
    final p = PosThemeExtension.light;
    expect(p.elevFlat, 0);
    expect(p.elevPaper, lessThan(p.elevPaperActive));
    expect(p.elevPaperActive, lessThan(p.elevChrome));
    expect(p.elevChrome, lessThan(p.elevFab));
    expect(p.elevFab, lessThanOrEqualTo(p.elevFabActive));
    expect(p.elevFabActive, p.elevModal);
  });

  test('shadow recipes are non-empty dual dock / chrome', () {
    final p = PosThemeExtension.light;
    expect(p.shadowDockUp, hasLength(2));
    expect(p.shadowChromeDown, hasLength(1));
    expect(p.shadowFabCta, hasLength(1));
    expect(p.shadowDockUp.first.blurRadius, 16);
    // Dark ambient slightly stronger than light.
    expect(
      PosThemeExtension.dark.shadowDockFarAlpha,
      greaterThan(PosThemeExtension.light.shadowDockFarAlpha),
    );
  });

  testWidgets('posTheme falls back to light when extension missing', (
    tester,
  ) async {
    late PosThemeExtension ext;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            ext = context.posTheme;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(ext.catalogBackground, PosThemeExtension.light.catalogBackground);
  });

  testWidgets('posTheme reads extension from ThemeData', (tester) async {
    late PosThemeExtension ext;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [PosThemeExtension.dark]),
        home: Builder(
          builder: (context) {
            ext = context.posTheme;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(ext.catalogBackground, PosThemeExtension.dark.catalogBackground);
  });
}
