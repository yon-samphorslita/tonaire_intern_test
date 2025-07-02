import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool isLoading = false;

  List<Product> get products => _products;

  Future<void> fetchProducts({
    String searchTerm = '',
    String sortBy = 'productid',
    int page = 1,
    bool append = false,
  }) async {
    if (page == 1 && !append) {
      isLoading = true;
      notifyListeners();
    }

    try {
      final fetched = await ApiService.fetchProducts(
        searchTerm: searchTerm,
        sortBy: sortBy,
        page: page,
      );

      if (append) {
        _products.addAll(fetched);
      } else {
        _products = fetched;
      }
    } catch (_) {
      if (!append) _products = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    await ApiService.addProduct(product);
    await fetchProducts();
  }

  Future<void> updateProduct(int id, Product product) async {
    await ApiService.updateProduct(id, product);
    await fetchProducts();
  }

  Future<void> deleteProduct(int id) async {
    await ApiService.deleteProduct(id);
    await fetchProducts();
  }
}
