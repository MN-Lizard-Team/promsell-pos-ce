import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_empty_state.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('SearchEmptyState', () {
    testWidgets('renders start typing message when query is empty', (
      tester,
    ) async {
      await tester.pumpApp(const SearchEmptyState(query: ''));

      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('renders no matching message when query is set', (
      tester,
    ) async {
      await tester.pumpApp(const SearchEmptyState(query: 'coffee'));

      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.textContaining('coffee'), findsOneWidget);
    });

    testWidgets('renders clear action when query is set and onClear provided', (
      tester,
    ) async {
      await tester.pumpApp(SearchEmptyState(query: 'coffee', onClear: () {}));

      expect(find.text('Clear search'), findsOneWidget);
    });

    testWidgets('does not render clear action when query is empty', (
      tester,
    ) async {
      await tester.pumpApp(const SearchEmptyState(query: ''));

      expect(find.text('Clear search'), findsNothing);
    });
  });
}
