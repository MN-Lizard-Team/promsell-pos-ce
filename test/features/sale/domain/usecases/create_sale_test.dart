import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/usecases/create_sale.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late CreateSale useCase;
  late MockSaleRepository mockRepo;

  setUp(() {
    mockRepo = MockSaleRepository();
    useCase = CreateSale(mockRepo);
  });

  setUpAll(() {
    registerFallbackValue(<CartItem>[]);
    registerFallbackValue('');
  });

  test('delegates to repository.createSale', () async {
    when(
      () => mockRepo.createSale(
        items: any(named: 'items'),
        paymentMethod: any(named: 'paymentMethod'),
        vatMode: any(named: 'vatMode'),
        vatRate: any(named: 'vatRate'),
        amountReceived: any(named: 'amountReceived'),
        changeAmount: any(named: 'changeAmount'),
        note: any(named: 'note'),
        paymentReference: any(named: 'paymentReference'),
      ),
    ).thenAnswer((_) async => tSale);

    final result = await useCase(
      items: [tCartItem],
      paymentMethod: 'cash',
      vatMode: 'NONE',
      vatRate: 0,
      amountReceived: 500.0,
      changeAmount: 300.0,
    );

    expect(result, tSale);
    verify(
      () => mockRepo.createSale(
        items: [tCartItem],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
        amountReceived: 500.0,
        changeAmount: 300.0,
        paymentReference: null,
      ),
    ).called(1);
  });
}
