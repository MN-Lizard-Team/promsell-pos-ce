import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';

class SearchHistoryState {
  const SearchHistoryState({this.searches = const []});
  final List<String> searches;

  SearchHistoryState copyWith({List<String>? searches}) {
    return SearchHistoryState(searches: searches ?? this.searches);
  }
}

class SearchHistoryCubit extends Cubit<SearchHistoryState> {
  SearchHistoryCubit(this._datasource, this._key)
    : super(const SearchHistoryState());

  final SettingsLocalDatasource _datasource;
  final String _key;

  Future<void> load() async {
    final raw = await _datasource.getString(_key);
    if (raw == null || raw.isEmpty) {
      emit(const SearchHistoryState());
      return;
    }
    try {
      final list = (jsonDecode(raw) as List).cast<String>();
      emit(SearchHistoryState(searches: list));
    } catch (_) {
      emit(const SearchHistoryState());
    }
  }

  Future<void> add(String query) async {
    if (query.trim().isEmpty) return;
    final q = query.trim();
    var list = [q, ...state.searches.where((s) => s != q)];
    if (list.length > 10) list = list.sublist(0, 10);
    await _persist(list);
  }

  Future<void> remove(String query) async {
    final list = state.searches.where((s) => s != query).toList();
    await _persist(list);
  }

  Future<void> clear() async {
    await _persist([]);
  }

  Future<void> _persist(List<String> list) async {
    await _datasource.setString(_key, jsonEncode(list));
    emit(SearchHistoryState(searches: list));
  }
}
