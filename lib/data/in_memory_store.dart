import 'package:flutter/material.dart';

import '../domain/product.dart';

class InMemoryStore {
  static final ValueNotifier<List<Product>> products = ValueNotifier(
    [
      const Product(id: 'p1', name: '低刺激の洗顔', category: '洗顔'),
      const Product(id: 'p2', name: '保湿化粧水', category: '化粧水'),
      const Product(id: 'p3', name: 'クリーム', category: '乳液・クリーム'),
    ],
  );

  static const List<String> productCategories = [
    '洗顔',
    '化粧水',
    '乳液・クリーム',
    '美容液',
    '日焼け止め',
    'その他',
  ];

  static void addProduct(Product product) {
    products.value = [...products.value, product];
  }

  static void removeProduct(String productId) {
    products.value = products.value
        .where((product) => product.id != productId)
        .toList();
  }
}
