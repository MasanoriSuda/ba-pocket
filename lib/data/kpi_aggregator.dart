import '../domain/kpi_summary.dart';
import 'event_logger.dart';
import 'event_log_entry.dart';
import 'event_log_repository.dart';

class KpiAggregator {
  KpiAggregator({EventLogRepository? repository})
      : _repository = repository ?? EventLogRepository();

  final EventLogRepository _repository;

  Future<KpiSummary> loadSummary({DateTime? now}) async {
    final DateTime end = now ?? DateTime.now();
    final DateTime start = end.subtract(const Duration(days: 14));
    final events = _repository.getSince(start);

    final consultationStarted =
        _uniqueByConsultation(events, EventType.consultationStarted);
    final consultationCompleted =
        _uniqueByConsultation(events, EventType.consultationCompleted);
    final recommendationViewed =
        _uniqueByConsultation(events, EventType.recommendationViewed);

    final recommendationStatuses =
        _firstStatusByConsultation(events, EventType.recommendationExecuted);
    final executedAll = recommendationStatuses.values
        .where((status) => status == 'all')
        .length;
    final executedAllOrPartial = recommendationStatuses.values
        .where((status) => status == 'all' || status == 'partial')
        .length;

    final secondVisitRate = _computeSecondVisitRate(events);
    final anxietyRelief = _computeAverage(events, 'anxiety_score');
    final referralIntent = _computeAverage(events, 'referral_intent');

    return KpiSummary(
      consultationCompletion: KpiRate(
        numerator: consultationCompleted.length,
        denominator: consultationStarted.length,
      ),
      recommendationReach: KpiRate(
        numerator: recommendationViewed.length,
        denominator: consultationCompleted.length,
      ),
      recommendationExecutedAll: KpiRate(
        numerator: executedAll,
        denominator: recommendationViewed.length,
      ),
      recommendationExecutedAllOrPartial: KpiRate(
        numerator: executedAllOrPartial,
        denominator: recommendationViewed.length,
      ),
      secondVisitRate: secondVisitRate,
      anxietyRelief: anxietyRelief,
      referralIntent: referralIntent,
      since: start,
      until: end,
    );
  }

  Set<String> _uniqueByConsultation(
    List<EventLogEntry> events,
    String eventType,
  ) {
    final ids = <String>{};
    for (final event in events) {
      if (event.eventType != eventType) continue;
      if (event.consultationId == 'none') continue;
      ids.add(event.consultationId);
    }
    return ids;
  }

  Map<String, String> _firstStatusByConsultation(
    List<EventLogEntry> events,
    String eventType,
  ) {
    final statuses = <String, String>{};
    for (final event in events) {
      if (event.eventType != eventType) continue;
      if (event.consultationId == 'none') continue;
      if (statuses.containsKey(event.consultationId)) continue;
      final status = event.payload['status'] as String?;
      if (status == null) continue;
      statuses[event.consultationId] = status;
    }
    return statuses;
  }

  KpiRate _computeSecondVisitRate(List<EventLogEntry> events) {
    final firstViewByUser = <String, DateTime>{};
    for (final event in events) {
      if (event.eventType != EventType.recommendationViewed) continue;
      final existing = firstViewByUser[event.userId];
      if (existing == null || event.timestamp.isBefore(existing)) {
        firstViewByUser[event.userId] = event.timestamp;
      }
    }

    int numerator = 0;
    for (final entry in firstViewByUser.entries) {
      final userId = entry.key;
      final firstViewedAt = entry.value;
      final deadline = firstViewedAt.add(const Duration(days: 7));
      final hasSecond = events.any(
        (event) =>
            event.userId == userId &&
            event.eventType == EventType.consultationStarted &&
            event.timestamp.isAfter(firstViewedAt) &&
            event.timestamp.isBefore(deadline),
      );
      if (hasSecond) {
        numerator += 1;
      }
    }

    return KpiRate(
      numerator: numerator,
      denominator: firstViewByUser.length,
    );
  }

  KpiAverage _computeAverage(List<EventLogEntry> events, String key) {
    double total = 0;
    int count = 0;
    for (final event in events) {
      if (event.eventType != EventType.followupSubmitted) continue;
      final value = event.payload[key];
      if (value is num) {
        total += value.toDouble();
        count += 1;
      }
    }
    if (count == 0) {
      return const KpiAverage(value: null, count: 0);
    }
    return KpiAverage(value: total / count, count: count);
  }
}
