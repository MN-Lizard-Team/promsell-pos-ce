import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';

enum CategoryStatus { initial, loading, success, failure }

enum CategorySaveStatus { idle, saving, saved, error }

class CategoryState extends Equatable {
  const CategoryState({
    this.status = CategoryStatus.initial,
    this.categories = const [],
    this.errorMessage,
    this.saveStatus = CategorySaveStatus.idle,
  });

  final CategoryStatus status;
  final List<Category> categories;
  final String? errorMessage;
  final CategorySaveStatus saveStatus;

  CategoryState copyWith({
    CategoryStatus? status,
    List<Category>? categories,
    Object? errorMessage,
    CategorySaveStatus? saveStatus,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      errorMessage: errorMessage is String? ? errorMessage : this.errorMessage,
      saveStatus: saveStatus ?? this.saveStatus,
    );
  }

  @override
  List<Object?> get props => [status, categories, errorMessage, saveStatus];
}
