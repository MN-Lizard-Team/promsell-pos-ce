import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/add_category.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/delete_category.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/reorder_categories.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/update_category.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/watch_categories.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';

class _CategoriesUpdated extends CategoryEvent {
  const _CategoriesUpdated(this.categories);
  final List<Category> categories;
  @override
  List<Object?> get props => [categories];
}

class _CategoriesError extends CategoryEvent {
  const _CategoriesError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

@lazySingleton
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc({
    required WatchCategories watchCategories,
    required AddCategory addCategory,
    required UpdateCategory updateCategory,
    required DeleteCategory deleteCategory,
    required ReorderCategories reorderCategories,
  }) : _watchCategories = watchCategories,
       _addCategory = addCategory,
       _updateCategory = updateCategory,
       _deleteCategory = deleteCategory,
       _reorderCategories = reorderCategories,
       super(const CategoryState()) {
    _startWatching();
    on<_CategoriesUpdated>(_onUpdated);
    on<_CategoriesError>(_onError);
    on<CategoryAdded>(_onAdded);
    on<CategoryUpdated>(_onCategoryUpdated);
    on<CategoryDeleted>(_onDeleted);
    on<CategoriesReordered>(_onReordered);
  }

  final WatchCategories _watchCategories;
  final AddCategory _addCategory;
  final UpdateCategory _updateCategory;
  final DeleteCategory _deleteCategory;
  final ReorderCategories _reorderCategories;
  StreamSubscription<List<Category>>? _sub;

  void _startWatching() {
    _sub?.cancel();
    _sub = _watchCategories().listen(
      (categories) => add(_CategoriesUpdated(categories)),
      onError: (Object e) => add(_CategoriesError(e.toString())),
    );
  }

  void _onUpdated(_CategoriesUpdated event, Emitter<CategoryState> emit) {
    emit(
      state.copyWith(
        status: CategoryStatus.success,
        categories: event.categories,
        errorMessage: null,
        saveStatus: CategorySaveStatus.idle,
      ),
    );
  }

  void _onError(_CategoriesError event, Emitter<CategoryState> emit) {
    emit(
      state.copyWith(
        status: CategoryStatus.failure,
        errorMessage: event.message,
      ),
    );
  }

  Future<void> _onAdded(
    CategoryAdded event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(saveStatus: CategorySaveStatus.saving));
    try {
      await _addCategory(
        name: event.name,
        sortOrder: event.sortOrder,
        color: event.color,
        iconName: event.iconName,
      );
      emit(state.copyWith(saveStatus: CategorySaveStatus.saved));
    } catch (e) {
      emit(
        state.copyWith(
          saveStatus: CategorySaveStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCategoryUpdated(
    CategoryUpdated event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(saveStatus: CategorySaveStatus.saving));
    try {
      await _updateCategory(event.category);
      emit(state.copyWith(saveStatus: CategorySaveStatus.saved));
    } catch (e) {
      emit(
        state.copyWith(
          saveStatus: CategorySaveStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleted(
    CategoryDeleted event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(saveStatus: CategorySaveStatus.saving));
    try {
      await _deleteCategory(event.id);
      emit(state.copyWith(saveStatus: CategorySaveStatus.saved));
    } catch (e) {
      emit(
        state.copyWith(
          saveStatus: CategorySaveStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onReordered(
    CategoriesReordered event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(saveStatus: CategorySaveStatus.saving));
    try {
      await _reorderCategories(event.orderedIds);
      emit(state.copyWith(saveStatus: CategorySaveStatus.saved));
    } catch (e) {
      emit(
        state.copyWith(
          saveStatus: CategorySaveStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
