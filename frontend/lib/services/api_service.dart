import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/products'; 

  static Future<List<Product>> fetchProducts({String searchTerm = '', String sortBy = 'productid', int page = 1}) async {
    final query = {
      'search': searchTerm,
      'sort': sortBy,
      'page': page.toString(),
    };
    final uri = Uri.parse(baseUrl).replace(queryParameters: query);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<Product> fetchProductById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));  // Changed here
    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load product');
    }
  }

  static Future<void> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add product');
    }
  }

  static Future<void> updateProduct(int id, Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),   // Changed here
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update product');
    }
  }

  static Future<void> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));  // Changed here
    if (response.statusCode != 200) {
      throw Exception('Failed to delete product');
    }
  }
}
