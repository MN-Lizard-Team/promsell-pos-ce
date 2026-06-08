sealed class SaleFailure {
  const SaleFailure(this.message);
  final String message;
}

class SaleCreateFailure extends SaleFailure {
  const SaleCreateFailure(super.message);
}

class SaleLoadFailure extends SaleFailure {
  const SaleLoadFailure(super.message);
}

class SaleVoidFailure extends SaleFailure {
  const SaleVoidFailure(super.message);
}
