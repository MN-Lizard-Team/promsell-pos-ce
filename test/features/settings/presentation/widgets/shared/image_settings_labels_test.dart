import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/image_settings_labels.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  group('image_settings_labels', () {
    group('qualityLabel', () {
      test('returns Draft quality for <= 50', () {
        expect(qualityLabel(40, l10n), l10n.imageQualityDraft);
        expect(qualityLabel(50, l10n), l10n.imageQualityDraft);
      });

      test('returns Standard quality for 51-70', () {
        expect(qualityLabel(60, l10n), l10n.imageQualityStandard);
        expect(qualityLabel(70, l10n), l10n.imageQualityStandard);
      });

      test('returns High quality for 71-80', () {
        expect(qualityLabel(75, l10n), l10n.imageQualityHigh);
        expect(qualityLabel(80, l10n), l10n.imageQualityHigh);
      });

      test('returns Best quality for 81-90', () {
        expect(qualityLabel(85, l10n), l10n.imageQualityBest);
        expect(qualityLabel(90, l10n), l10n.imageQualityBest);
      });

      test('returns Original quality for > 90', () {
        expect(qualityLabel(95, l10n), l10n.imageQualityOriginal);
        expect(qualityLabel(100, l10n), l10n.imageQualityOriginal);
      });
    });

    group('widthLabel', () {
      test('returns Small size for <= 400', () {
        expect(widthLabel(300, l10n), l10n.imageWidthSmall);
        expect(widthLabel(400, l10n), l10n.imageWidthSmall);
      });

      test('returns Medium size for 401-600', () {
        expect(widthLabel(500, l10n), l10n.imageWidthMedium);
        expect(widthLabel(600, l10n), l10n.imageWidthMedium);
      });

      test('returns Large size for 601-800', () {
        expect(widthLabel(700, l10n), l10n.imageWidthLarge);
        expect(widthLabel(800, l10n), l10n.imageWidthLarge);
      });

      test('returns Extra large size for 801-1200', () {
        expect(widthLabel(1000, l10n), l10n.imageWidthExtraLarge);
        expect(widthLabel(1200, l10n), l10n.imageWidthExtraLarge);
      });

      test('returns Full HD size for > 1200', () {
        expect(widthLabel(1600, l10n), l10n.imageWidthFullHD);
      });
    });
  });
}
