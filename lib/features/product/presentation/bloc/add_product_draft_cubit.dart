import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';

class AddProductDraftState extends Equatable {
  const AddProductDraftState({this.hasDraft = false, this.draft = const {}});

  final bool hasDraft;
  final Map<String, dynamic> draft;

  AddProductDraftState copyWith({bool? hasDraft, Map<String, dynamic>? draft}) {
    return AddProductDraftState(
      hasDraft: hasDraft ?? this.hasDraft,
      draft: draft ?? this.draft,
    );
  }

  @override
  List<Object?> get props => [hasDraft, draft];
}

class AddProductDraftCubit extends Cubit<AddProductDraftState> {
  AddProductDraftCubit(this._storage) : super(const AddProductDraftState()) {
    _loadFromStorage();
  }

  final SettingsLocalDatasource _storage;
  static const _key = 'add_product_draft_v2';

  Future<void> _loadFromStorage() async {
    final raw = await _storage.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        emit(state.copyWith(hasDraft: true, draft: decoded));
      } catch (_) {
        await _storage.setString(_key, '');
      }
    }
  }

  Future<void> saveDraft(Map<String, dynamic> values) async {
    emit(state.copyWith(hasDraft: true, draft: values));
    await _storage.setString(_key, jsonEncode(values));
  }

  Future<void> clearDraft() async {
    emit(const AddProductDraftState());
    await _storage.setString(_key, '');
  }

  Map<String, dynamic>? loadDraft() {
    return state.hasDraft ? state.draft : null;
  }
}
