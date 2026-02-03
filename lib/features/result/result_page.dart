import 'package:flutter/material.dart';

import '../../data/analytics_context.dart';
import '../../data/event_logger.dart';
import '../../domain/consultation_input.dart';
import '../../domain/product.dart';
import '../../domain/recommendation.dart';
import '../../domain/rule_engine.dart';
import '../../shared/category_mapper.dart';
import '../follow_up/follow_up_page.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({
    super.key,
    required this.input,
    required this.selectedProducts,
    required this.consultationId,
  });

  final ConsultationInput input;
  final List<Product> selectedProducts;
  final String consultationId;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late final Recommendation _recommendation;
  late final String _recommendationId;
  String? _executionStatus;
  bool _executionLogged = false;

  @override
  void initState() {
    super.initState();
    _recommendation = RuleEngine().generate(
      input: widget.input,
      products: widget.selectedProducts,
    );
    _recommendationId = AnalyticsContext.newRecommendationId();
    EventLogger.logRecommendationGenerated(
      consultationId: widget.consultationId,
      recommendationId: _recommendationId,
    );
    _logViewedEvents();
  }

  void _logViewedEvents() {
    final selectedCategories = _recommendation.useNow
        .map((item) => mapCategoryKey(item.product.category))
        .toSet()
        .toList();
    final skippedCategories = _recommendation.restNow
        .map((item) => mapCategoryKey(item.product.category))
        .toSet()
        .toList();
    final safetyLevel = _safetyLevel(widget.input.intensity);
    EventLogger.logRecommendationViewed(
      consultationId: widget.consultationId,
      recommendationId: _recommendationId,
      selectedCategories: selectedCategories,
      skippedCategories: skippedCategories,
      safetyLevel: safetyLevel,
    );
    EventLogger.logSafetyNoticeViewed(consultationId: widget.consultationId);
    if (_showMedicalPrompt) {
      EventLogger.logMedicalPromptShown(consultationId: widget.consultationId);
    }
  }

  bool get _showMedicalPrompt => widget.input.intensity == '強';

  String _safetyLevel(String intensity) {
    switch (intensity) {
      case '弱':
        return 'low';
      case '中':
        return 'medium';
      case '強':
        return 'high';
      default:
        return 'unknown';
    }
  }

  void _selectExecutionStatus(String status) {
    if (_executionLogged) return;
    setState(() {
      _executionStatus = status;
      _executionLogged = true;
    });
    EventLogger.logRecommendationExecuted(
      consultationId: widget.consultationId,
      recommendationId: _recommendationId,
      status: status,
      selectedProductIds: widget.selectedProducts.map((p) => p.id).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('今夜の指示'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            '方針',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(_recommendation.summary),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recommendation.tags
                .map(
                  (tag) => Chip(label: Text(tag)),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(
            '今夜使う',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (_recommendation.useNow.isEmpty)
            const Text('使える手持ちがありません。')
          else
            ..._recommendation.useNow.map(
              (item) => Text('・${item.product.name}（${item.reason}）'),
            ),
          const SizedBox(height: 16),
          Text(
            '今夜休む',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (_recommendation.restNow.isEmpty)
            const Text('休むものはありません。')
          else
            ..._recommendation.restNow.map(
              (item) => Text('・${item.product.name}（${item.reason}）'),
            ),
          const SizedBox(height: 16),
          Text(
            '手順',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ..._recommendation.steps.asMap().entries.map(
                (entry) => Text('${entry.key + 1}) ${entry.value}'),
              ),
          const SizedBox(height: 16),
          Text(
            '明日どうなったら変更するか',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(_recommendation.watchRule),
          const SizedBox(height: 16),
          Text(
            '今夜の実行予定',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('全部やる'),
                selected: _executionStatus == 'all',
                onSelected: _executionLogged
                    ? null
                    : (_) => _selectExecutionStatus('all'),
              ),
              ChoiceChip(
                label: const Text('一部だけ'),
                selected: _executionStatus == 'partial',
                onSelected: _executionLogged
                    ? null
                    : (_) => _selectExecutionStatus('partial'),
              ),
              ChoiceChip(
                label: const Text('やらない'),
                selected: _executionStatus == 'none',
                onSelected: _executionLogged
                    ? null
                    : (_) => _selectExecutionStatus('none'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '注意事項',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('本アプリは医療的な診断を行いません。'),
                const Text('強い痛み・広範な腫れ・発熱・化膿などがある場合は受診してください。'),
                if (_showMedicalPrompt) ...[
                  const SizedBox(height: 8),
                  const Text('症状が強い場合は早めの受診を検討してください。'),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FollowUpPage(
                    consultationId: widget.consultationId,
                  ),
                ),
              );
            },
            child: const Text('翌日フォローへ'),
          ),
        ],
      ),
    );
  }
}
