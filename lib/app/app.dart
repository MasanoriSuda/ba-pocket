import 'package:flutter/material.dart';

import '../features/home/home_page.dart';
import 'theme.dart';

class BaPocketApp extends StatelessWidget {
  const BaPocketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BA Pocket',
      theme: AppTheme.light(),
      home: const HomePage(),
    );
  }
}
