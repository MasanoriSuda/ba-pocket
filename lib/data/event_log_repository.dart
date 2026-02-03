import 'package:hive_flutter/hive_flutter.dart';

import 'event_log_entry.dart';
import 'hive_boxes.dart';

class EventLogRepository {
  Box<Map> get _box => Hive.box<Map>(HiveBoxes.eventLogs);

  Future<void> log(EventLogEntry entry) async {
    await _box.add(entry.toMap());
  }

  List<EventLogEntry> getAll() {
    return _box.values
        .map((raw) => EventLogEntry.fromMap(raw))
        .toList();
  }

  List<EventLogEntry> getSince(DateTime since) {
    return getAll()
        .where((entry) => entry.timestamp.isAfter(since))
        .toList();
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
