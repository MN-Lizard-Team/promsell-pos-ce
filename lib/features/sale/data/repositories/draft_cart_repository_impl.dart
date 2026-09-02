import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/draft_cart_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_snapshot.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/draft_cart.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/kitchen_ticket.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/draft_cart_repository.dart';

@LazySingleton(as: DraftCartRepository)
class DraftCartRepositoryImpl implements DraftCartRepository {
  const DraftCartRepositoryImpl(this._datasource);
  final DraftCartLocalDatasource _datasource;

  @override
  Future<String> createDraft({String? name}) =>
      _datasource.createDraft(name: name);

  @override
  Future<void> saveDraft(
    String cartId,
    CartSnapshot snapshot, {
    String? name,
  }) => _datasource.upsertDraft(cartId, snapshot, name: name);

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
  Future<({int draftCount, int openBillCount})> getDraftCounts() =>
      _datasource.getDraftCounts();

  @override
  Future<KitchenTicket> fireUnfiredLines(String cartId) =>
      _datasource.fireUnfiredLines(cartId);

  @override
  Future<void> transferDraftCart({
    required String cartId,
    required String sourceTableId,
    required String targetTableId,
  }) => _datasource.transferDraftCart(
    cartId: cartId,
    sourceTableId: sourceTableId,
    targetTableId: targetTableId,
  );

  @override
  Future<int> archiveOldDrafts(DateTime cutoff) =>
      _datasource.archiveOldDrafts(cutoff);
}
