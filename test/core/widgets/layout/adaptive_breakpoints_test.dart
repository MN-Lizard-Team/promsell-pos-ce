import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/layout/adaptive_breakpoints.dart';

void main() {
  group('AdaptiveBreakpoints', () {
    testWidgets('isCompact returns true for width < 600', (tester) async {
      tester.view.physicalSize = const Size(500, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: _BreakpointTester())),
      );

      final state = tester.state<_BreakpointTesterState>(
        find.byType(_BreakpointTester),
      );
      expect(AdaptiveBreakpoints.isCompact(state.context), isTrue);
      expect(AdaptiveBreakpoints.isMedium(state.context), isFalse);
      expect(AdaptiveBreakpoints.isExpanded(state.context), isFalse);
    });

    testWidgets('isMedium returns true for 600 <= width < 840', (tester) async {
      tester.view.physicalSize = const Size(700, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: _BreakpointTester())),
      );

      final state = tester.state<_BreakpointTesterState>(
        find.byType(_BreakpointTester),
      );
      expect(AdaptiveBreakpoints.isCompact(state.context), isFalse);
      expect(AdaptiveBreakpoints.isMedium(state.context), isTrue);
      expect(AdaptiveBreakpoints.isExpanded(state.context), isFalse);
    });

    testWidgets('isExpanded returns true for width >= 840', (tester) async {
      tester.view.physicalSize = const Size(900, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: _BreakpointTester())),
      );

      final state = tester.state<_BreakpointTesterState>(
        find.byType(_BreakpointTester),
      );
      expect(AdaptiveBreakpoints.isCompact(state.context), isFalse);
      expect(AdaptiveBreakpoints.isMedium(state.context), isFalse);
      expect(AdaptiveBreakpoints.isExpanded(state.context), isTrue);
    });
  });
}

class _BreakpointTester extends StatefulWidget {
  const _BreakpointTester();

  @override
  State<_BreakpointTester> createState() => _BreakpointTesterState();
}

class _BreakpointTesterState extends State<_BreakpointTester> {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
