class CartItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String size;
  final String color;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.size,
    required this.color,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  CartItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? image,
    String? size,
    String? color,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      size: size ?? this.size,
      color: color ?? this.color,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'size': size,
      'color': color,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String,
      size: json['size'] as String,
      color: json['color'] as String,
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  static List<CartItem> getSampleItems() {
    return [
      CartItem(
        id: 'prod_001',
        name: 'Premium Cotton T-Shirt',
        description: 'Comfortable, breathable cotton blend perfect for everyday wear',
        price: 1299.00,
        image: '👕',
        size: 'M',
        color: 'Navy Blue',
        quantity: 1,
      ),
      CartItem(
        id: 'prod_002',
        name: 'Classic V-Neck Tee',
        description: 'Timeless style with a modern fit',
        price: 899.00,
        image: '👔',
        size: 'L',
        color: 'White',
        quantity: 2,
      ),
    ];
  }
}
