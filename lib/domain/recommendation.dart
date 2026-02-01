import 'product.dart';

class RecommendationItem {
  const RecommendationItem({
    required this.product,
    required this.reason,
  });

  final Product product;
  final String reason;
}

class Recommendation {
  const Recommendation({
    required this.summary,
    required this.tags,
    required this.useNow,
    required this.restNow,
    required this.steps,
    required this.watchRule,
  });

  final String summary;
  final List<String> tags;
  final List<RecommendationItem> useNow;
  final List<RecommendationItem> restNow;
  final List<String> steps;
  final String watchRule;
}
