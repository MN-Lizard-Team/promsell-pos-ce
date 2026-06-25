import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/stock/stock_stepper.dart';

void main() {
  group('StockStepper', () {
    testWidgets('tap + increments value by 1', (tester) async {
      var value = 10;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) => StockStepper(
                  value: value,
                  onChanged: (v) => setState(() => value = v),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(value, 11);
    });

    testWidgets('tap - decrements value by 1', (tester) async {
      var value = 10;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) => StockStepper(
                  value: value,
                  onChanged: (v) => setState(() => value = v),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(value, 9);
    });

    testWidgets('tap + at max does not increment', (tester) async {
      var value = 9999;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) => StockStepper(
                  value: value,
                  max: 9999,
                  onChanged: (v) => setState(() => value = v),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(value, 9999);
    });

    testWidgets('tap - at min does not decrement', (tester) async {
      var value = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) => StockStepper(
                  value: value,
                  min: 0,
                  onChanged: (v) => setState(() => value = v),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(value, 0);
    });

    testWidgets('long-press + continuously increments', (tester) async {
      var value = 10;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) => StockStepper(
                  value: value,
                  onChanged: (v) => setState(() => value = v),
                ),
              ),
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byIcon(Icons.add)),
      );
      await tester.pump();

      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(value, greaterThan(11));

      await gesture.up();
      await tester.pump();

      final valueAfterRelease = value;
      await tester.pump(const Duration(milliseconds: 200));
      expect(value, valueAfterRelease);
    });

    testWidgets('long-press - continuously decrements', (tester) async {
      var value = 100;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) => StockStepper(
                  value: value,
                  onChanged: (v) => setState(() => value = v),
                ),
              ),
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byIcon(Icons.remove)),
      );
      await tester.pump();

      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(value, lessThan(99));

      await gesture.up();
      await tester.pump();

      final valueAfterRelease = value;
      await tester.pump(const Duration(milliseconds: 200));
      expect(value, valueAfterRelease);
    });

    testWidgets('onQtyTap callback fires when tapping the number', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: StockStepper(
                value: 5,
                onChanged: (_) {},
                onQtyTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('5'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('long-press stops at max', (tester) async {
      var value = 9997;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) => StockStepper(
                  value: value,
                  max: 9999,
                  onChanged: (v) => setState(() => value = v),
                ),
              ),
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byIcon(Icons.add)),
      );
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 600));
      expect(value, lessThanOrEqualTo(9999));

      await gesture.up();
      await tester.pump();
    });
  });
}
