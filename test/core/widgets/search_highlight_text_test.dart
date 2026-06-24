import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_highlight_text.dart';

void main() {
  testWidgets('renders plain Text when query is empty', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SearchHighlightText(text: 'Hello World', query: ''),
        ),
      ),
    );

    expect(find.byType(Text), findsOneWidget);
    expect(find.text('Hello World'), findsOneWidget);
  });

  testWidgets('renders RichText when query matches', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SearchHighlightText(text: 'Hello World', query: 'World'),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets('renders plain Text when query has no match', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SearchHighlightText(text: 'Hello World', query: 'xyz'),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets('case-insensitive matching works', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SearchHighlightText(text: 'Hello World', query: 'WORLD'),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets('handles multiple matches', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SearchHighlightText(text: 'ab ab ab', query: 'ab'),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
    final richText = tester.widget<RichText>(find.byType(RichText));
    final span = richText.text as TextSpan;
    expect(span.children, isNotNull);
    expect(span.children!.length, 5);
  });
}
