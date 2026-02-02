import 'package:flutter/material.dart';

class FollowUpPage extends StatefulWidget {
  const FollowUpPage({super.key});

  @override
  State<FollowUpPage> createState() => _FollowUpPageState();
}

class _FollowUpPageState extends State<FollowUpPage> {
  String? _outcome;
  final TextEditingController _memoController = TextEditingController();

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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('記録しました（PoCは端末内のみ）。')),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
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
