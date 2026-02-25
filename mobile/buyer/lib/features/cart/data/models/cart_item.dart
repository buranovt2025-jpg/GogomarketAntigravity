class CartItem {
  final String productId;
  final String productName;
  final double price;
  final List<String> images;
  int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.images,
    this.quantity = 1,
  });

  double get subtotal => price * quantity;
}
