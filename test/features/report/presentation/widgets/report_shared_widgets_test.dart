import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/close_day_cta.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/report_date_filter_header.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/report_section_card.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: child),
    );
  }

  testWidgets('ReportSectionCard shows title and child', (tester) async {
    await tester.pumpWidget(
      wrap(
        const ReportSectionCard(
          title: 'Section',
          icon: Icons.bar_chart,
          child: Text('body-content'),
        ),
      ),
    );
    expect(find.text('Section'), findsOneWidget);
    expect(find.text('body-content'), findsOneWidget);
    expect(find.byIcon(Icons.bar_chart), findsOneWidget);
  });

  testWidgets('CloseDayCta button invokes onPressed', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrap(CloseDayCta(label: 'Close day', onPressed: () => tapped = true)),
    );
    await tester.tap(find.text('Close day'));
    expect(tapped, isTrue);
  });

  testWidgets('ReportDateFilterHeader renders range label', (tester) async {
    final from = DateTime(2026, 8, 1);
    final to = DateTime(2026, 8, 5);
    final fmt = DateFormat('yyyy-MM-dd');
    await tester.pumpWidget(
      wrap(
        ReportDateFilterHeader(
          from: from,
          to: to,
          fmt: fmt,
          onPreset: (_, _) {},
          onPick: () {},
        ),
      ),
    );
    expect(find.textContaining('2026-08-01'), findsOneWidget);
  });
}
