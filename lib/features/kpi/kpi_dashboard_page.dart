// KPI Dashboard Page
import 'package:flutter/material.dart';

import '../../data/event_log_repository.dart';
import '../../data/kpi_aggregator.dart';
import '../../domain/kpi_summary.dart';

class KpiDashboardPage extends StatefulWidget {
  const KpiDashboardPage({super.key});

  @override
  State<KpiDashboardPage> createState() => _KpiDashboardPageState();
}

class _KpiDashboardPageState extends State<KpiDashboardPage> {
  late Future<KpiSummary> _future;
  final KpiAggregator _aggregator = KpiAggregator();
  final EventLogRepository _repository = EventLogRepository();

  @override
  void initState() {
    super.initState();
    _future = _aggregator.loadSummary();
  }

  void _reload() {
    setState(() {
      _future = _aggregator.loadSummary();
    });
  }

  Future<void> _resetData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('データをリセットしますか？'),
        content: const Text('端末内のEventLogがすべて削除されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('削除する'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _repository.clearAll();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('EventLogを削除しました。')),
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KPI一覧'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<KpiSummary>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('KPIがまだありません。'));
          }
          final summary = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                '直近14日（${_formatDate(summary.since)}〜${_formatDate(summary.until)}）',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              _RateTile(
                title: '問診完了率',
                rate: summary.consultationCompletion,
              ),
              _RateTile(
                title: '提案到達率',
                rate: summary.recommendationReach,
              ),
              _RateTile(
                title: '提案実行率（all）',
                rate: summary.recommendationExecutedAll,
              ),
              _RateTile(
                title: '提案実行率（all+partial）',
                rate: summary.recommendationExecutedAllOrPartial,
              ),
              _RateTile(
                title: '2回目利用率（7日以内）',
                rate: summary.secondVisitRate,
              ),
              _AverageTile(
                title: '不安低減（1〜5）',
                average: summary.anxietyRelief,
                maxValue: 5,
              ),
              _AverageTile(
                title: '紹介意向（0〜10）',
                average: summary.referralIntent,
                maxValue: 10,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _resetData,
                child: const Text('データリセット'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}

class _RateTile extends StatelessWidget {
  const _RateTile({
    required this.title,
    required this.rate,
  });

  final String title;
  final KpiRate rate;

  @override
  Widget build(BuildContext context) {
    final percent = (rate.value * 100).toStringAsFixed(0);
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text('分子/分母: ${rate.numerator}/${rate.denominator}'),
        trailing: Text('$percent%'),
      ),
    );
  }
}

class _AverageTile extends StatelessWidget {
  const _AverageTile({
    required this.title,
    required this.average,
    required this.maxValue,
  });

  final String title;
  final KpiAverage average;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    final valueText = average.value == null
        ? '--'
        : average.value!.toStringAsFixed(1);
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text('回答数: ${average.count}'),
        trailing: Text('$valueText / $maxValue'),
      ),
    );
  }
}
