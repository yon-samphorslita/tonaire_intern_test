class Product {
  final int? id;
  final String name;
  final double price;
  final int stock;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['PRODUCTID'],
        name: json['PRODUCTNAME'],
        price: json['PRICE'].toDouble(),
        stock: json['STOCK'],
      );

  Map<String, dynamic> toJson() => {
        'productName': name,
        'price': price,
        'stock': stock,
      };
}
