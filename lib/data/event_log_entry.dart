class EventLogEntry {
  const EventLogEntry({
    required this.userId,
    required this.sessionId,
    required this.consultationId,
    required this.timestamp,
    required this.eventType,
    required this.payload,
  });

  final String userId;
  final String sessionId;
  final String consultationId;
  final DateTime timestamp;
  final String eventType;
  final Map<String, dynamic> payload;

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'session_id': sessionId,
      'consultation_id': consultationId,
      'timestamp': timestamp.toIso8601String(),
      'event_type': eventType,
      'payload': payload,
    };
  }

  static EventLogEntry fromMap(Map<dynamic, dynamic> map) {
    return EventLogEntry(
      userId: map['user_id'] as String? ?? 'unknown',
      sessionId: map['session_id'] as String? ?? 'unknown',
      consultationId: map['consultation_id'] as String? ?? 'none',
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      eventType: map['event_type'] as String? ?? 'unknown',
      payload: Map<String, dynamic>.from(
        (map['payload'] as Map?) ?? const <String, dynamic>{},
      ),
    );
  }
}
