import '../shared/category_mapper.dart';
import 'analytics_context.dart';
import 'event_log_entry.dart';
import 'event_log_repository.dart';

class EventType {
  EventType._();

  static const String appOpened = 'app_opened';
  static const String consultationStarted = 'consultation_started';
  static const String consultationCompleted = 'consultation_completed';
  static const String consultationAbandoned = 'consultation_abandoned';
  static const String productsRegistered = 'products_registered';
  static const String recommendationGenerated = 'recommendation_generated';
  static const String recommendationViewed = 'recommendation_viewed';
  static const String recommendationExecuted = 'recommendation_executed';
  static const String followupOpened = 'followup_opened';
  static const String followupSubmitted = 'followup_submitted';
  static const String safetyNoticeViewed = 'safety_notice_viewed';
  static const String medicalPromptShown = 'medical_prompt_shown';
}

class EventLogger {
  EventLogger._();

  static final EventLogRepository _repository = EventLogRepository();

  static Future<void> logAppOpened() {
    return _log(eventType: EventType.appOpened);
  }

  static Future<void> logConsultationStarted({
    required String consultationId,
  }) {
    return _log(
      eventType: EventType.consultationStarted,
      consultationId: consultationId,
    );
  }

  static Future<void> logConsultationCompleted({
    required String consultationId,
  }) {
    return _log(
      eventType: EventType.consultationCompleted,
      consultationId: consultationId,
    );
  }

  static Future<void> logConsultationAbandoned({
    required String consultationId,
    required int stepIndex,
    required int elapsedMs,
  }) {
    return _log(
      eventType: EventType.consultationAbandoned,
      consultationId: consultationId,
      payload: {
        'step_index': stepIndex,
        'elapsed_ms': elapsedMs,
      },
    );
  }

  static Future<void> logProductsRegistered({
    required int count,
    required Map<String, int> categoriesSummary,
  }) {
    return _log(
      eventType: EventType.productsRegistered,
      payload: {
        'count': count,
        'categories_summary': categoriesSummary,
      },
    );
  }

  static Future<void> logRecommendationGenerated({
    required String consultationId,
    required String recommendationId,
  }) {
    return _log(
      eventType: EventType.recommendationGenerated,
      consultationId: consultationId,
      payload: {
        'recommendation_id': recommendationId,
      },
    );
  }

  static Future<void> logRecommendationViewed({
    required String consultationId,
    required String recommendationId,
    required List<String> selectedCategories,
    required List<String> skippedCategories,
    required String safetyLevel,
  }) {
    return _log(
      eventType: EventType.recommendationViewed,
      consultationId: consultationId,
      payload: {
        'recommendation_id': recommendationId,
        'selected_categories': selectedCategories,
        'skipped_categories': skippedCategories,
        'safety_level': safetyLevel,
      },
    );
  }

  static Future<void> logRecommendationExecuted({
    required String consultationId,
    required String recommendationId,
    required String status,
    required List<String> selectedProductIds,
  }) {
    return _log(
      eventType: EventType.recommendationExecuted,
      consultationId: consultationId,
      payload: {
        'recommendation_id': recommendationId,
        'status': status,
        'selected_product_ids': selectedProductIds,
      },
    );
  }

  static Future<void> logFollowupOpened({
    required String consultationId,
  }) {
    return _log(
      eventType: EventType.followupOpened,
      consultationId: consultationId,
    );
  }

  static Future<void> logFollowupSubmitted({
    required String consultationId,
    required String result,
    required int notesLength,
    int? anxietyScore,
    int? referralIntent,
  }) {
    return _log(
      eventType: EventType.followupSubmitted,
      consultationId: consultationId,
      payload: {
        'result': result,
        'notes_length': notesLength,
        if (anxietyScore != null) 'anxiety_score': anxietyScore,
        if (referralIntent != null) 'referral_intent': referralIntent,
      },
    );
  }

  static Future<void> logSafetyNoticeViewed({
    required String consultationId,
  }) {
    return _log(
      eventType: EventType.safetyNoticeViewed,
      consultationId: consultationId,
    );
  }

  static Future<void> logMedicalPromptShown({
    required String consultationId,
  }) {
    return _log(
      eventType: EventType.medicalPromptShown,
      consultationId: consultationId,
    );
  }

  static Map<String, int> buildCategorySummary(List<String> categories) {
    final summary = <String, int>{};
    for (final category in categories) {
      final key = mapCategoryKey(category);
      summary.update(key, (value) => value + 1, ifAbsent: () => 1);
    }
    return summary;
  }

  static Future<void> _log({
    required String eventType,
    String consultationId = 'none',
    Map<String, dynamic> payload = const {},
  }) async {
    final entry = EventLogEntry(
      userId: AnalyticsContext.userId,
      sessionId: AnalyticsContext.sessionId,
      consultationId: consultationId,
      timestamp: DateTime.now(),
      eventType: eventType,
      payload: payload,
    );
    await _repository.log(entry);
  }
}
