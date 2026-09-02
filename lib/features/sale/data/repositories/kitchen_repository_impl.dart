import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/draft_cart_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/kitchen_ticket.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/kitchen_repository.dart';

@LazySingleton(as: KitchenRepository)
class KitchenRepositoryImpl implements KitchenRepository {
  const KitchenRepositoryImpl(this._datasource);
  final DraftCartLocalDatasource _datasource;

  @override
  Future<KitchenTicket> fireUnfiredLines(String cartId) =>
      _datasource.fireUnfiredLines(cartId);
}
