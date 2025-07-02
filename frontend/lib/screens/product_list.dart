import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import 'add_product.dart';
import 'edit_product.dart';
import 'dart:async';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();
  String _searchTerm = '';
  String _sortBy = 'PRODUCTID';
  int _page = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchTerm = query;
        _page = 1;
      });
      _fetchProducts();
    });
  }

  Future<void> _fetchProducts() async {
    await Provider.of<ProductProvider>(context, listen: false)
        .fetchProducts(searchTerm: _searchTerm, sortBy: _sortBy.toLowerCase(), page: _page);
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    _page++;
    await Provider.of<ProductProvider>(context, listen: false)
        .fetchProducts(searchTerm: _searchTerm, sortBy: _sortBy.toLowerCase(), page: _page, append: true);
    setState(() => _isLoadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Manager'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurple.shade400,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Sort by: ', style: TextStyle(color: Colors.white)),
                    DropdownButton<String>(
                      value: _sortBy,
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      items: const [
                        DropdownMenuItem(value: 'PRODUCTID', child: Text('Default')),
                        DropdownMenuItem(value: 'PRICE', child: Text('Price')),
                        DropdownMenuItem(value: 'STOCK', child: Text('Stock')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _sortBy = value!;
                          _page = 1;
                        });
                        _fetchProducts();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: provider.isLoading && provider.products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                _page = 1;
                await _fetchProducts();
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: provider.products.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (_, index) {
                  if (index == provider.products.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final product = provider.products[index];

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Price: \$${product.price.toStringAsFixed(2)} • Stock: ${product.stock}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.deepPurple),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditProduct(product: product),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.deepPurple),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: const Text('Are you sure you want to delete this product?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm ?? false) {
                                await provider.deleteProduct(product.id!);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddProduct()),
        ),
        label: const Text('Add', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
