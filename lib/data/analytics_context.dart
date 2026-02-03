import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import 'hive_boxes.dart';

class AnalyticsContext {
  AnalyticsContext._();

  static const _userIdKey = 'user_id';
  static final Uuid _uuid = Uuid();

  static String? _userId;
  static String? _sessionId;

  static Future<void> init() async {
    final metaBox = Hive.box<String>(HiveBoxes.appMeta);
    final storedUserId = metaBox.get(_userIdKey);
    if (storedUserId == null) {
      _userId = _uuid.v4();
      await metaBox.put(_userIdKey, _userId!);
    } else {
      _userId = storedUserId;
    }
    _sessionId = _uuid.v4();
  }

  static String get userId {
    if (_userId == null) {
      throw StateError('AnalyticsContext.init() must be called before use.');
    }
    return _userId!;
  }

  static String get sessionId {
    if (_sessionId == null) {
      throw StateError('AnalyticsContext.init() must be called before use.');
    }
    return _sessionId!;
  }

  static String newConsultationId() => _uuid.v4();

  static String newRecommendationId() => _uuid.v4();
}
