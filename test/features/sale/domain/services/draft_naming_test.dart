import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/draft_naming.dart';

void main() {
  final fixed = DateTime(2026, 1, 1, 9, 5);

  group('DraftNaming.autoName', () {
    test('tableId wins over time', () {
      expect(
        DraftNaming.autoName(tableId: 'T-5', itemCount: 3, now: fixed),
        'T-5',
      );
    });

    test('empty bill is B-HHmm', () {
      expect(DraftNaming.autoName(itemCount: 0, now: fixed), 'B-0905');
    });

    test('non-empty is B-HHmm · N', () {
      expect(DraftNaming.autoName(itemCount: 2, now: fixed), 'B-0905 · 2');
    });

    test('blank table falls through to time', () {
      expect(
        DraftNaming.autoName(tableId: '  ', itemCount: 0, now: fixed),
        'B-0905',
      );
    });
  });

  group('DraftNaming.forNewEmptyBill', () {
    test('matches empty autoName', () {
      expect(DraftNaming.forNewEmptyBill(now: fixed), 'B-0905');
    });
  });

  group('DraftNaming.shortTableRef', () {
    test('short ids pass through unchanged', () {
      expect(DraftNaming.shortTableRef('T-5'), 'T-5');
    });

    test('uuids are trimmed to their first segment', () {
      expect(
        DraftNaming.shortTableRef('3f9c2a1e-88aa-4d0f-b6f3-a1b2c3d4e5f6'),
        '3f9c2a1e',
      );
    });

    test('trims surrounding whitespace first', () {
      expect(DraftNaming.shortTableRef(' ab12cd34-rest '), 'ab12cd34');
    });
  });

  group('DraftNaming.resolveParkName', () {
    test('keeps existing name when no explicit', () {
      expect(
        DraftNaming.resolveParkName(
          tableId: null,
          itemCount: 1,
          existingName: 'VIP',
          now: fixed,
        ),
        'VIP',
      );
    });

    test('auto when no existing and no explicit', () {
      expect(
        DraftNaming.resolveParkName(tableId: null, itemCount: 1, now: fixed),
        'B-0905 · 1',
      );
    });

    test('explicit non-empty wins', () {
      expect(
        DraftNaming.resolveParkName(
          tableId: null,
          itemCount: 1,
          explicitName: 'Table 7',
          existingName: 'VIP',
          now: fixed,
        ),
        'Table 7',
      );
    });

    test('explicit empty falls to auto', () {
      expect(
        DraftNaming.resolveParkName(
          tableId: null,
          itemCount: 1,
          explicitName: '  ',
          existingName: 'VIP',
          now: fixed,
        ),
        'B-0905 · 1',
      );
    });

    test('uses tableId when provided', () {
      expect(
        DraftNaming.resolveParkName(tableId: 'T-5', itemCount: 0, now: fixed),
        'T-5',
      );
    });
  });
}
