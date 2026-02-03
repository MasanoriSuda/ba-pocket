class KpiRate {
  const KpiRate({
    required this.numerator,
    required this.denominator,
  });

  final int numerator;
  final int denominator;

  double get value {
    if (denominator == 0) return 0;
    return numerator / denominator;
  }
}

class KpiAverage {
  const KpiAverage({
    required this.value,
    required this.count,
  });

  final double? value;
  final int count;
}

class KpiSummary {
  const KpiSummary({
    required this.consultationCompletion,
    required this.recommendationReach,
    required this.recommendationExecutedAll,
    required this.recommendationExecutedAllOrPartial,
    required this.secondVisitRate,
    required this.anxietyRelief,
    required this.referralIntent,
    required this.since,
    required this.until,
  });

  final KpiRate consultationCompletion;
  final KpiRate recommendationReach;
  final KpiRate recommendationExecutedAll;
  final KpiRate recommendationExecutedAllOrPartial;
  final KpiRate secondVisitRate;
  final KpiAverage anxietyRelief;
  final KpiAverage referralIntent;
  final DateTime since;
  final DateTime until;
}
