import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'data/analytics_context.dart';
import 'data/hive_boxes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<String>(HiveBoxes.appMeta);
  await Hive.openBox<Map>(HiveBoxes.eventLogs);
  await AnalyticsContext.init();
  runApp(const BaPocketApp());
}
