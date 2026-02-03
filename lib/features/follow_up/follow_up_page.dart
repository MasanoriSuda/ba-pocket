import 'package:flutter/material.dart';

import '../../data/event_logger.dart';

class FollowUpPage extends StatefulWidget {
  const FollowUpPage({
    super.key,
    required this.consultationId,
  });

  final String consultationId;

  @override
  State<FollowUpPage> createState() => _FollowUpPageState();
}

class _FollowUpPageState extends State<FollowUpPage> {
  String? _outcome;
  int? _anxietyScore;
  int? _referralIntent;
  final TextEditingController _memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    EventLogger.logFollowupOpened(consultationId: widget.consultationId);
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_outcome == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('結果を選んでください。')),
      );
      return;
    }
    final mapped = _mapOutcome(_outcome!);
    EventLogger.logFollowupSubmitted(
      consultationId: widget.consultationId,
      result: mapped,
      notesLength: _memoController.text.trim().length,
      anxietyScore: _anxietyScore,
      referralIntent: _referralIntent,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('記録しました（PoCは端末内のみ）。')),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  String _mapOutcome(String value) {
    switch (value) {
      case '良くなった':
        return 'improved';
      case '変わらない':
        return 'same';
      case '悪化した':
        return 'worse';
      default:
        return 'unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('翌日フォロー'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '翌日の状態を教えてください',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            RadioListTile<String>(
              value: '良くなった',
              groupValue: _outcome,
              onChanged: (value) => setState(() => _outcome = value),
              title: const Text('良くなった'),
            ),
            RadioListTile<String>(
              value: '変わらない',
              groupValue: _outcome,
              onChanged: (value) => setState(() => _outcome = value),
              title: const Text('変わらない'),
            ),
            RadioListTile<String>(
              value: '悪化した',
              groupValue: _outcome,
              onChanged: (value) => setState(() => _outcome = value),
              title: const Text('悪化した'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _anxietyScore,
              items: List.generate(
                5,
                (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text('${index + 1}'),
                ),
              ),
              onChanged: (value) => setState(() => _anxietyScore = value),
              decoration: const InputDecoration(
                labelText: '不安は減りましたか（1〜5）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _referralIntent,
              items: List.generate(
                11,
                (index) => DropdownMenuItem(
                  value: index,
                  child: Text('$index'),
                ),
              ),
              onChanged: (value) => setState(() => _referralIntent = value),
              decoration: const InputDecoration(
                labelText: '紹介意向（0〜10）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _memoController,
              decoration: const InputDecoration(
                labelText: 'メモ（任意）',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const Spacer(),
            FilledButton(
              onPressed: _submit,
              child: const Text('記録して終了'),
            ),
          ],
        ),
      ),
    );
  }
}
