import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/get_daily_close_preview.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_summary.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart';

class MockSaleRepository extends Mock implements SaleRepository {}

void main() {
  late MockSaleRepository sales;
  late GetDailyClosePreview usecase;

  setUp(() {
    sales = MockSaleRepository();
    usecase = GetDailyClosePreview(sales);
  });

  test('maps aggregate totals and cash tenders without persisting', () async {
    when(
      () => sales.getReportSummary(
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer(
      (_) async => const ReportSummary(
        netRevenue: Money.fromSatang(125000),
        voidedTotal: Money.fromSatang(5000),
        salesCount: 4,
        voidCount: 1,
        vatAmount: Money.fromSatang(8750),
        discountAmount: Money.fromSatang(1200),
        serviceChargeAmount: Money.zero,
        promotionDiscountAmount: Money.fromSatang(300),
        paymentBreakdown: {'cash': 700.0, 'promptpay': 550.0},
        paymentCounts: {'cash': 3, 'promptpay': 2},
        orderTypeBreakdown: {},
        orderChannelBreakdown: {},
        voidReasonBreakdown: {},
        promotionCount: 1,
      ),
    );

    final result = await usecase('2026-06-05');

    expect(result.salesCount, 4);
    expect(result.voidCount, 1);
    expect(result.netRevenue, Money.fromDouble(1250));
    expect(result.voidedTotal, Money.fromDouble(50));
    expect(result.cashSales, Money.fromDouble(700));
    expect(result.discountAmount, Money.fromDouble(15));
    verify(
      () => sales.getReportSummary(
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).called(1);
  });

  test('rejects malformed dates before querying sales', () async {
    expect(() => usecase('05-06-2026'), throwsA(isA<FormatException>()));
    verifyNever(
      () => sales.getReportSummary(
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    );
  });
}
