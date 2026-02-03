import 'package:flutter/material.dart';

import '../../data/in_memory_store.dart';
import '../../domain/consultation_input.dart';
import '../../domain/product.dart';
import '../result/result_page.dart';
import 'products_page.dart';

class ProductSelectPage extends StatefulWidget {
  const ProductSelectPage({
    super.key,
    required this.input,
    required this.consultationId,
  });

  final ConsultationInput input;
  final String consultationId;

  @override
  State<ProductSelectPage> createState() => _ProductSelectPageState();
}

class _ProductSelectPageState extends State<ProductSelectPage> {
  final Set<String> _selectedIds = {};

  List<Product> _selectedProducts(List<Product> products) {
    return products.where((product) => _selectedIds.contains(product.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('手持ちを選ぶ'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProductsPage()),
              );
            },
            child: const Text('管理'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('今夜使えそうなものを選んでください。'),
            const SizedBox(height: 12),
            Expanded(
              child: ValueListenableBuilder<List<Product>>(
                valueListenable: InMemoryStore.products,
                builder: (context, products, _) {
                  if (products.isEmpty) {
                    return const Center(child: Text('手持ちがまだ登録されていません。'));
                  }
                  return ListView(
                    children: products
                        .map(
                          (product) => CheckboxListTile(
                            value: _selectedIds.contains(product.id),
                            title: Text(product.name),
                            subtitle: Text(product.category),
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedIds.add(product.id);
                                } else {
                                  _selectedIds.remove(product.id);
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<List<Product>>(
              valueListenable: InMemoryStore.products,
              builder: (context, products, _) {
                final selected = _selectedProducts(products);
                return FilledButton(
                  onPressed: selected.isEmpty
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ResultPage(
                                input: widget.input,
                                selectedProducts: selected,
                                consultationId: widget.consultationId,
                              ),
                            ),
                          );
                        },
                  child: const Text('結果を見る'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
