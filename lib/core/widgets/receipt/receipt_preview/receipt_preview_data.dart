class ReceiptPreviewItem {
  const ReceiptPreviewItem({
    required this.name,
    required this.qty,
    required this.price,
    required this.subtotal,
    this.imagePath,
    this.imageThumbnailPath,
    this.imageUrl,
  });

  final String name;
  final int qty;
  final double price;
  final double subtotal;
  final String? imagePath;
  final String? imageThumbnailPath;
  final String? imageUrl;
}

enum ReceiptPreviewStyle { thermal, card, none }
