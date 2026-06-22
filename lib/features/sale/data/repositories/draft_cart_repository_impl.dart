import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/draft_cart_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/draft_cart.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/draft_cart_repository.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';

@LazySingleton(as: DraftCartRepository)
class DraftCartRepositoryImpl implements DraftCartRepository {
  const DraftCartRepositoryImpl(this._datasource);
  final DraftCartLocalDatasource _datasource;

  @override
  Future<String> createDraft({String? name}) =>
      _datasource.createDraft(name: name);

  @override
  Future<void> saveDraft(String cartId, CartState state, {String? name}) =>
      _datasource.upsertDraft(cartId, state, name: name);

  @override
  Future<DraftCart?> loadDraft(String cartId) => _datasource.loadDraft(cartId);

  @override
  Future<List<DraftCart>> listDrafts({bool includeArchived = false}) =>
      _datasource.listDrafts(includeArchived: includeArchived);

  @override
  Future<void> deleteDraft(String cartId) => _datasource.deleteDraft(cartId);

  @override
  Future<void> renameDraft(String cartId, String name) =>
      _datasource.renameDraft(cartId, name);

  @override
  Future<int> countDrafts() => _datasource.countDrafts();

  @override
  Future<int> archiveOldDrafts(DateTime cutoff) =>
      _datasource.archiveOldDrafts(cutoff);
}
