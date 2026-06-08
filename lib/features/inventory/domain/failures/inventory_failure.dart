sealed class InventoryFailure {
  const InventoryFailure(this.message);
  final String message;
}

class InventoryLogLoadFailure extends InventoryFailure {
  const InventoryLogLoadFailure(super.message);
}

class InventoryAdjustFailure extends InventoryFailure {
  const InventoryAdjustFailure(super.message);
}
