import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_draft.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/generate_barcode.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_form_state.dart';

export 'package:promsell_pos_ce/features/product/presentation/bloc/product_form_state.dart';

@injectable
class ProductFormCubit extends Cubit<ProductFormState> {
  ProductFormCubit(this._storage, this._generateBarcode)
    : super(const ProductFormState()) {
    _loadDraftFromStorage();
  }

  final SettingsLocalDatasource _storage;
  final GenerateBarcode _generateBarcode;
  static const _draftKey = 'product_form_draft_v3';

  final Completer<void> _draftLoaded = Completer<void>();
  Future<void> get draftLoaded => _draftLoaded.future;

  void _loadDraftFromStorage() async {
    try {
      final raw = await _storage.getString(_draftKey);
      if (isClosed) return;
      if (raw != null && raw.isNotEmpty) {
        try {
          final decoded = jsonDecode(raw) as Map<String, dynamic>;
          final draft = ProductDraft.fromJson(decoded);
          if (!draft.isEmpty) {
            emit(state.copyWith(draft: draft, isDirty: true));
          }
        } catch (_) {
          await _storage.setString(_draftKey, '');
        }
      }
    } finally {
      if (!_draftLoaded.isCompleted) _draftLoaded.complete();
    }
  }

  ProductDraft get draft => state.draft;
  bool get isDirty => state.isDirty;
  bool get isSubmitted => state.isSubmitted;

  void updateField(ProductDraft Function(ProductDraft) mapper) {
    emit(state.copyWith(draft: mapper(state.draft), isDirty: true));
  }

  void updateImage(String? imagePath, String? thumbnailPath) {
    emit(
      state.copyWith(
        draft: state.draft.copyWith(
          imagePath: imagePath,
          imageThumbnailPath: thumbnailPath,
        ),
        isDirty: true,
      ),
    );
  }

  void setSubmitted() {
    emit(state.copyWith(isSubmitted: true, status: ProductFormStatus.saving));
  }

  void resetSubmitted() {
    emit(
      state.copyWith(
        isSubmitted: false,
        status: ProductFormStatus.idle,
        errorMessage: null,
      ),
    );
  }

  void setSaved() {
    emit(state.copyWith(status: ProductFormStatus.saved));
  }

  void setError(String message) {
    emit(
      state.copyWith(status: ProductFormStatus.error, errorMessage: message),
    );
  }

  Future<void> generateBarcode({String? prefix, String? excludeId}) async {
    try {
      final barcode = await _generateBarcode(
        prefix: prefix,
        excludeId: excludeId,
      );
      emit(
        state.copyWith(
          draft: state.draft.copyWith(barcode: barcode),
          isDirty: true,
        ),
      );
    } catch (e, stack) {
      AppLogger.error(
        'ProductFormCubit.generateBarcode failed',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  ProductDraft collectDraft() => state.draft;

  Future<void> saveDraftToStorage() async {
    if (!state.isDirty || state.isSubmitted) return;
    try {
      await _storage.setString(_draftKey, jsonEncode(state.draft.toJson()));
    } catch (e) {
      AppLogger.warning('ProductFormCubit.saveDraftToStorage failed', error: e);
    }
  }

  Future<void> clearDraft() async {
    emit(state.copyWith(draft: const ProductDraft(), isDirty: false));
    try {
      await _storage.setString(_draftKey, '');
    } catch (e) {
      AppLogger.warning('ProductFormCubit.clearDraft failed', error: e);
    }
  }

  void restoreDraft(ProductDraft draft) {
    emit(state.copyWith(draft: draft, isDirty: true));
  }

  void syncDraftFromControllers({
    required String name,
    required String price,
    required String stock,
    required String sku,
    required String barcode,
    required String cost,
    String? categoryId,
    String? categoryName,
    String? imagePath,
    String? imageThumbnailPath,
    required bool trackStock,
    bool isActive = true,
  }) {
    emit(
      state.copyWith(
        draft: ProductDraft(
          name: name,
          price: price,
          stock: stock,
          sku: sku,
          barcode: barcode,
          cost: cost,
          categoryId: categoryId,
          categoryName: categoryName,
          imagePath: imagePath,
          imageThumbnailPath: imageThumbnailPath,
          trackStock: trackStock,
          isActive: isActive,
        ),
        isDirty: true,
      ),
    );
  }

  void reset() {
    emit(const ProductFormState());
  }
}
