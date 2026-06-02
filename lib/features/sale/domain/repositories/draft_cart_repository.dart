import 'package:promsell_pos_ce/features/sale/domain/entities/draft_cart.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';

abstract class DraftCartRepository {
  Future<String> createDraft({String? name});
  Future<void> saveDraft(String cartId, SaleState state, {String? name});
  Future<DraftCart?> loadDraft(String cartId);
  Future<List<DraftCart>> listDrafts({bool includeArchived = false});
  Future<void> deleteDraft(String cartId);
  Future<void> renameDraft(String cartId, String name);
  Future<int> countDrafts();
  Future<int> archiveOldDrafts(DateTime cutoff);
}
