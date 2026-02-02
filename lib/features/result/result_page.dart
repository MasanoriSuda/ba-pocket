import 'package:flutter/material.dart';

import '../../domain/consultation_input.dart';
import '../../domain/product.dart';
import '../../domain/rule_engine.dart';
import '../follow_up/follow_up_page.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({
    super.key,
    required this.input,
    required this.selectedProducts,
  });

  final ConsultationInput input;
  final List<Product> selectedProducts;

  @override
  Widget build(BuildContext context) {
    final recommendation = RuleEngine().generate(
      input: input,
      products: selectedProducts,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('今夜の指示'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            '方針',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(recommendation.summary),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recommendation.tags
                .map(
                  (tag) => Chip(label: Text(tag)),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(
            '今夜使う',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (recommendation.useNow.isEmpty)
            const Text('使える手持ちがありません。')
          else
            ...recommendation.useNow.map(
              (item) => Text('・${item.product.name}（${item.reason}）'),
            ),
          const SizedBox(height: 16),
          Text(
            '今夜休む',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (recommendation.restNow.isEmpty)
            const Text('休むものはありません。')
          else
            ...recommendation.restNow.map(
              (item) => Text('・${item.product.name}（${item.reason}）'),
            ),
          const SizedBox(height: 16),
          Text(
            '手順',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...recommendation.steps.asMap().entries.map(
                (entry) => Text('${entry.key + 1}) ${entry.value}'),
              ),
          const SizedBox(height: 16),
          Text(
            '明日どうなったら変更するか',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(recommendation.watchRule),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '注意事項',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('本アプリは医療的な診断を行いません。'),
                Text('強い痛み・広範な腫れ・発熱・化膿などがある場合は受診してください。'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const FollowUpPage()),
              );
            },
            child: const Text('翌日フォローへ'),
          ),
        ],
      ),
    );
  }
}
