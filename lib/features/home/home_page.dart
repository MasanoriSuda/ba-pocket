import 'package:flutter/material.dart';

import '../consultation/consultation_page.dart';
import '../products/products_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BA Pocket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '今夜の肌荒れケア',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const Text(
              '30秒問診で、家にあるもので今夜のケアを提案します。',
            ),
            const Spacer(),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ConsultationPage(),
                  ),
                );
              },
              child: const Text('問診を始める'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProductsPage(),
                  ),
                );
              },
              child: const Text('手持ちを管理'),
            ),
          ],
        ),
      ),
    );
  }
}
