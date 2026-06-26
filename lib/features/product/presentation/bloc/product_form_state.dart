import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_draft.dart';

enum ProductFormStatus { idle, saving, saved, error }

class ProductFormState extends Equatable {
  const ProductFormState({
    this.draft = const ProductDraft(),
    this.status = ProductFormStatus.idle,
    this.isDirty = false,
    this.isSubmitted = false,
    this.errorMessage,
  });

  final ProductDraft draft;
  final ProductFormStatus status;
  final bool isDirty;
  final bool isSubmitted;
  final String? errorMessage;

  ProductFormState copyWith({
    ProductDraft? draft,
    ProductFormStatus? status,
    bool? isDirty,
    bool? isSubmitted,
    String? errorMessage,
  }) {
    return ProductFormState(
      draft: draft ?? this.draft,
      status: status ?? this.status,
      isDirty: isDirty ?? this.isDirty,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    draft,
    status,
    isDirty,
    isSubmitted,
    errorMessage,
  ];
}
