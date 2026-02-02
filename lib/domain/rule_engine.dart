import 'consultation_input.dart';
import 'product.dart';
import 'recommendation.dart';

class RuleEngine {
  Recommendation generate({
    required ConsultationInput input,
    required List<Product> products,
  }) {
    if (products.isEmpty) {
      return const Recommendation(
        summary: '手持ちが登録されていないため、今夜は最小限のケアにしましょう。',
        tags: ['最小限ケア'],
        useNow: [],
        restNow: [],
        steps: ['洗顔はやさしく短時間で行いましょう。'],
        watchRule: '赤みやヒリつきが強くなる場合は使用を中止してください。',
      );
    }

    final tags = _buildTags(input);
    final maxUse = input.intensity == '強' ? 2 : 3;
    final ordered = _orderProducts(products, tags);
    final useCandidates = ordered.where((product) {
      return product.category != '日焼け止め';
    }).toList();

    final useNow = useCandidates.take(maxUse).toList();
    final useIds = useNow.map((product) => product.id).toSet();
    final restNow = ordered.where((product) => !useIds.contains(product.id)).toList();

    final useItems = useNow
        .map(
          (product) => RecommendationItem(
            product: product,
            reason: _reasonForUse(product.category, input),
          ),
        )
        .toList();

    final restItems = restNow
        .map(
          (product) => RecommendationItem(
            product: product,
            reason: _reasonForRest(product.category, input),
          ),
        )
        .toList();

    return Recommendation(
      summary: _summary(input),
      tags: tags,
      useNow: useItems,
      restNow: restItems,
      steps: _buildSteps(useNow, tags),
      watchRule: _watchRule(input),
    );
  }

  List<String> _buildTags(ConsultationInput input) {
    final tags = <String>[];
    final sensitive = _hasSensitiveSigns(input);
    if (sensitive) {
      tags.add('刺激回避');
    }
    if (input.symptoms.contains('乾燥')) {
      tags.add('保湿優先');
    }
    if (input.symptoms.contains('ニキビっぽい')) {
      tags.add('油分控えめ');
      tags.add('洗浄丁寧');
    }
    if (input.symptoms.contains('赤み')) {
      tags.add('赤みケア');
    }
    if (input.symptoms.contains('かゆみ')) {
      tags.add('シンプルケア');
    }
    if (tags.isEmpty) {
      tags.add('バランス');
    }
    return tags;
  }

  List<Product> _orderProducts(List<Product> products, List<String> tags) {
    final scores = <String, int>{
      '洗顔': 30,
      '化粧水': 35,
      '乳液・クリーム': 30,
      '美容液': 20,
      'その他': 10,
      '日焼け止め': 0,
    };

    if (tags.contains('保湿優先')) {
      scores['化粧水'] = (scores['化粧水'] ?? 0) + 20;
      scores['乳液・クリーム'] = (scores['乳液・クリーム'] ?? 0) + 20;
    }
    if (tags.contains('刺激回避')) {
      scores['美容液'] = (scores['美容液'] ?? 0) - 15;
      scores['その他'] = (scores['その他'] ?? 0) - 10;
    }
    if (tags.contains('洗浄丁寧')) {
      scores['洗顔'] = (scores['洗顔'] ?? 0) + 10;
    }
    if (tags.contains('油分控えめ')) {
      scores['乳液・クリーム'] = (scores['乳液・クリーム'] ?? 0) - 5;
    }
    if (tags.contains('赤みケア')) {
      scores['化粧水'] = (scores['化粧水'] ?? 0) + 5;
    }

    final indexed = products.asMap().entries.toList();
    indexed.sort((a, b) {
      final scoreA = scores[a.value.category] ?? 0;
      final scoreB = scores[b.value.category] ?? 0;
      if (scoreA != scoreB) {
        return scoreB.compareTo(scoreA);
      }
      return a.key.compareTo(b.key);
    });
    return indexed.map((entry) => entry.value).toList();
  }

  bool _hasSensitiveSigns(ConsultationInput input) {
    return input.intensity == '強' ||
        input.symptoms.contains('赤み') ||
        input.symptoms.contains('ヒリつき') ||
        input.symptoms.contains('かゆみ');
  }

  String _summary(ConsultationInput input) {
    if (_hasSensitiveSigns(input)) {
      return '今夜は刺激を減らして保湿を優先します。';
    }
    if (input.symptoms.contains('乾燥')) {
      return 'うるおい補給を優先します。';
    }
    if (input.symptoms.contains('ニキビっぽい')) {
      return '洗浄と保湿を最小限にします。';
    }
    return 'シンプルに整えます。';
  }

  String _reasonForUse(String category, ConsultationInput input) {
    final tags = _buildTags(input);
    switch (category) {
      case '洗顔':
        return tags.contains('洗浄丁寧') ? '詰まりを減らすため' : '汚れをやさしく落とすため';
      case '化粧水':
        return tags.contains('赤みケア') ? '肌を落ち着かせるため' : 'うるおいを補うため';
      case '乳液・クリーム':
        return tags.contains('油分控えめ') ? '薄く保護するため' : '乾燥から守るため';
      case '美容液':
        return _hasSensitiveSigns(input) ? '刺激を避けて少量で様子見' : 'ポイントケアに';
      case '日焼け止め':
        return '夜は不要なため';
      default:
        return '必要最小限で使用';
    }
  }

  String _reasonForRest(String category, ConsultationInput input) {
    if (category == '日焼け止め') {
      return '夜なので休みましょう';
    }
    if (_hasSensitiveSigns(input)) {
      return '刺激になる可能性があるため';
    }
    if (input.symptoms.contains('ニキビっぽい') && category == '乳液・クリーム') {
      return '重く感じる場合は休みましょう';
    }
    return '今日はシンプルにするため';
  }

  List<String> _buildSteps(List<Product> useNow, List<String> tags) {
    final categories = useNow.map((product) => product.category).toSet();
    final steps = <String>[];
    if (tags.contains('刺激回避')) {
      steps.add('こすらずにやさしく触れる');
    }
    if (categories.contains('洗顔')) {
      steps.add('洗顔はやさしく短時間で');
    }
    if (categories.contains('化粧水')) {
      steps.add('化粧水は手のひらで軽く押さえる');
      if (tags.contains('保湿優先')) {
        steps.add('乾燥が強い部分は重ねづけ');
      }
    }
    if (categories.contains('美容液')) {
      steps.add('美容液は薄くポイント使い');
    }
    if (categories.contains('乳液・クリーム')) {
      steps.add(tags.contains('油分控えめ') ? 'クリームは薄く一部だけ' : 'クリームで薄くフタをする');
    }
    if (steps.isEmpty) {
      steps.add('今夜は刺激を避け、最小限のケアで様子見');
    }
    return steps;
  }

  String _watchRule(ConsultationInput input) {
    if (_hasSensitiveSigns(input)) {
      return '赤みやヒリつきが強くなる場合は使用を中止してください。';
    }
    if (input.symptoms.contains('ニキビっぽい')) {
      return 'ニキビが増える場合は使用を控えましょう。';
    }
    return '明日も同じ状態なら同じケアで様子見。';
  }
}
