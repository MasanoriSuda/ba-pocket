import 'package:flutter/material.dart';

import '../../data/analytics_context.dart';
import '../../data/event_logger.dart';
import '../../domain/consultation_input.dart';
import '../products/product_select_page.dart';

class ConsultationPage extends StatefulWidget {
  const ConsultationPage({super.key});

  @override
  State<ConsultationPage> createState() => _ConsultationPageState();
}

class _ConsultationPageState extends State<ConsultationPage> {
  late final String _consultationId;
  late final DateTime _startedAt;
  bool _completed = false;

  final Map<String, bool> _symptoms = {
    '赤み': false,
    'ヒリつき': false,
    '乾燥': false,
    'ニキビっぽい': false,
    'かゆみ': false,
  };

  String _intensity = '中';

  bool get _canProceed => _symptoms.values.any((value) => value);

  @override
  void initState() {
    super.initState();
    _consultationId = AnalyticsContext.newConsultationId();
    _startedAt = DateTime.now();
    EventLogger.logConsultationStarted(consultationId: _consultationId);
  }

  @override
  void dispose() {
    if (!_completed) {
      final elapsedMs = DateTime.now().difference(_startedAt).inMilliseconds;
      EventLogger.logConsultationAbandoned(
        consultationId: _consultationId,
        stepIndex: 1,
        elapsedMs: elapsedMs,
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('問診'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '気になる症状を選んでください',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  ..._symptoms.keys.map(
                    (symptom) => CheckboxListTile(
                      value: _symptoms[symptom],
                      title: Text(symptom),
                      onChanged: (value) {
                        setState(() {
                          _symptoms[symptom] = value ?? false;
                        });
                      },
                    ),
                  ),
                  const Divider(height: 24),
                  Text(
                    '症状の強さ',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  RadioListTile<String>(
                    value: '弱',
                    groupValue: _intensity,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _intensity = value;
                      });
                    },
                    title: const Text('弱い'),
                  ),
                  RadioListTile<String>(
                    value: '中',
                    groupValue: _intensity,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _intensity = value;
                      });
                    },
                    title: const Text('中くらい'),
                  ),
                  RadioListTile<String>(
                    value: '強',
                    groupValue: _intensity,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _intensity = value;
                      });
                    },
                    title: const Text('強い'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _canProceed
                  ? () {
                      _completed = true;
                      EventLogger.logConsultationCompleted(
                        consultationId: _consultationId,
                      );
                      final selectedSymptoms = _symptoms.entries
                          .where((entry) => entry.value)
                          .map((entry) => entry.key)
                          .toList();
                      final input = ConsultationInput(
                        symptoms: selectedSymptoms,
                        intensity: _intensity,
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProductSelectPage(
                            input: input,
                            consultationId: _consultationId,
                          ),
                        ),
                      );
                    }
                  : null,
              child: const Text('手持ちを選ぶ'),
            ),
          ],
        ),
      ),
    );
  }
}
