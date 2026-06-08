sealed class ProductFailure {
  const ProductFailure(this.message);
  final String message;
}

class ProductLoadFailure extends ProductFailure {
  const ProductLoadFailure(super.message);
}

class ProductSaveFailure extends ProductFailure {
  const ProductSaveFailure(super.message);
}

class ProductDeleteFailure extends ProductFailure {
  const ProductDeleteFailure(super.message);
}
