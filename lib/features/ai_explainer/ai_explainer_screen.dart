import 'package:flutter/material.dart';
import 'package:medly_app/controllers/app_state.dart';
import 'package:medly_app/models/lab_marker.dart';
import 'package:medly_app/theme/app_theme.dart';
import 'package:medly_app/widgets/medly_section_card.dart';
import 'package:provider/provider.dart';

class AIExplainerScreen extends StatefulWidget {
  const AIExplainerScreen({super.key});

  @override
  State<AIExplainerScreen> createState() => _AIExplainerScreenState();
}

class _AIExplainerScreenState extends State<AIExplainerScreen> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final explanation = state.explanation;
    final markers = state.markers;
    final overview = state.overview;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (state.hasLiveAI)
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: state.isGeneratingInsight ? null : () => context.read<AppState>().refreshAiExplanation(),
              icon: state.isGeneratingInsight
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_fix_high),
              label: const Text('Оновити через AI'),
            ),
          ),
        if (!state.hasLiveAI)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Демо режим. Додайте OPENAI_API_KEY через --dart-define, щоб отримати живий аналіз.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        if (state.aiError != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(state.aiError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        const SizedBox(height: 12),
        MedlySectionCard(
          title: 'Загальна картина',
          child: _ExplainerCard(
            body: overview,
            highlight: 'Знаю, іноді важко. Але залізо + вітамін D реально допоможуть відчути себе краще.',
          ),
        ),
        const SizedBox(height: 28),
        Text('Детальний розбір', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        ...markers.map(
          (marker) => _MarkerExplanation(
            marker: marker,
            text: explanation[marker.name] ?? 'Medly підлаштує цей маркер після завантаження аналізів.',
          ),
        ),
      ],
    );
  }
}

class _ExplainerCard extends StatelessWidget {
  const _ExplainerCard({required this.body, required this.highlight});

  final String body;
  final String highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(body, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.mint.withOpacity(.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_graph_rounded, color: AppTheme.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(highlight, style: Theme.of(context).textTheme.bodyLarge)),
            ],
          ),
        ),
      ],
    );
  }
}

class _MarkerExplanation extends StatelessWidget {
  const _MarkerExplanation({required this.marker, required this.text});

  final LabMarker marker;
  final String text;

  Color _dotColor(BuildContext context) {
    switch (marker.status) {
      case MarkerStatus.low:
        return AppTheme.warning;
      case MarkerStatus.high:
        return AppTheme.error;
      case MarkerStatus.normal:
        return AppTheme.success;
    }
  }

  String _status(BuildContext context) {
    switch (marker.status) {
      case MarkerStatus.low:
        return 'Трохи нижче норми';
      case MarkerStatus.high:
        return 'Трохи вище норми';
      case MarkerStatus.normal:
        return 'У межах норми';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.panel,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _dotColor(context).withOpacity(.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 6, backgroundColor: _dotColor(context)),
              const SizedBox(width: 8),
              Text(marker.name, style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text('${marker.value} ${marker.unit}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Text(_status(context), style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Text(text, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: const [
              _ActionChip(text: 'Їжа + залізо'),
              _ActionChip(text: 'Порадься з лікарем'),
              _ActionChip(text: 'Перездача 2-3 міс'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(text),
      backgroundColor: AppTheme.surface,
    );
  }
}
