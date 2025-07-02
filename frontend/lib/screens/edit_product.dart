import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class EditProduct extends StatefulWidget {
  final Product product;

  const EditProduct({super.key, required this.product});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late double price;
  late int stock;

  @override
  void initState() {
    super.initState();
    name = widget.product.name;
    price = widget.product.price;
    stock = widget.product.stock;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                onSaved: (value) => name = value!,
              ),
              TextFormField(
                initialValue: price.toString(),
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || double.tryParse(value) == null || double.parse(value) <= 0
                    ? 'Enter valid price'
                    : null,
                onSaved: (value) => price = double.parse(value!),
              ),
              TextFormField(
                initialValue: stock.toString(),
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
                    final updatedProduct = Product(id: widget.product.id, name: name, price: price, stock: stock);
                    await Provider.of<ProductProvider>(context, listen: false)
                        .updateProduct(widget.product.id!, updatedProduct);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Changes'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
