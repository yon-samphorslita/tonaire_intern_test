import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  double price = 0;
  int stock = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                onSaved: (value) => name = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || double.tryParse(value) == null || double.parse(value) <= 0
                    ? 'Enter valid price'
                    : null,
                onSaved: (value) => price = double.parse(value!),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || int.tryParse(value) == null || int.parse(value) < 0
                    ? 'Enter valid stock'
                    : null,
                onSaved: (value) => stock = int.parse(value!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final product = Product(name: name, price: price, stock: stock);
                    await Provider.of<ProductProvider>(context, listen: false).addProduct(product);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
