import 'package:flutter/material.dart';
import 'package:medly_app/controllers/app_state.dart';
import 'package:medly_app/models/action_item.dart';
import 'package:medly_app/models/lab_marker.dart';
import 'package:medly_app/theme/app_theme.dart';
import 'package:medly_app/widgets/medly_section_card.dart';
import 'package:provider/provider.dart';

class NextStepsScreen extends StatefulWidget {
  const NextStepsScreen({super.key});

  @override
  State<NextStepsScreen> createState() => _NextStepsScreenState();
}

enum PlanViewMode { timeline, checklist, compact }

class _NextStepsScreenState extends State<NextStepsScreen> {
  final Set<String> _completed = <String>{};
  PlanViewMode _viewMode = PlanViewMode.timeline;
  late final PageController _modeController;

  @override
  void initState() {
    super.initState();
    _modeController = PageController(initialPage: _viewMode.index, viewportFraction: .9);
  }

  @override
  void dispose() {
    _modeController.dispose();
    super.dispose();
  }

  String _planKey(ActionItem item) => '${item.title}|${item.description}';

  void _toggleComplete(ActionItem item) {
    final key = _planKey(item);
    setState(() {
      if (_completed.contains(key)) {
        _completed.remove(key);
      } else {
        _completed.add(key);
      }
    });
    final isDone = _completed.contains(key);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isDone ? 'Крок «${item.title}» відмічено як виконаний' : 'Повертаю крок «${item.title}» в план'),
      ),
    );
  }

  Future<void> _addManualStep() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    ActionTimeframe selectedTimeframe = ActionTimeframe.now;

    final result = await showModalBottomSheet<ActionItem>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Новий крок', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Назва'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Додай коротку назву' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Опис'),
                        maxLines: 3,
                        validator: (value) => value == null || value.trim().isEmpty ? 'Поясни, що саме зробити' : null,
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<ActionTimeframe>(
                        segments: const [
                          ButtonSegment(value: ActionTimeframe.now, label: Text('Цього тижня')),
                          ButtonSegment(value: ActionTimeframe.soon, label: Text('Наступного тижня')),
                          ButtonSegment(value: ActionTimeframe.later, label: Text('Через 2–3 місяці')),
                        ],
                        selected: {selectedTimeframe},
                        onSelectionChanged: (value) => setModalState(() => selectedTimeframe = value.first),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;
                          Navigator.of(context).pop(
                            ActionItem(
                              title: titleController.text.trim(),
                              description: descriptionController.text.trim(),
                              timeframe: selectedTimeframe,
                            ),
                          );
                        },
                        child: const Text('Зберегти'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null && mounted) {
      context.read<AppState>().addPlanItem(result);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Додано «${result.title}»')));
    }
  }

  void _generateAiSteps() {
    final state = context.read<AppState>();
    final markers = state.markers;
    final explanation = state.explanation;
    final List<ActionItem> suggestions = [];

    for (final marker in markers) {
      if (suggestions.length >= 3) break;
      final summary = explanation[marker.name] ?? '';
      final timeframe = marker.status == MarkerStatus.high || marker.status == MarkerStatus.low
          ? ActionTimeframe.now
          : ActionTimeframe.soon;
      suggestions.add(
        ActionItem(
          title: 'Підтримай ${marker.name}',
          description: summary.isNotEmpty
              ? summary
              : 'Додай рутину, щоб стабілізувати рівень ${marker.name}.',
          timeframe: timeframe,
        ),
      );
    }

    if (suggestions.isEmpty) {
      suggestions.add(
        const ActionItem(
          title: 'Повтори аналізи',
          description: 'Через кілька тижнів повтори панель, щоб бачити динаміку.',
          timeframe: ActionTimeframe.later,
        ),
      );
    }

    state.addPlanItems(suggestions);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Додано ${suggestions.length} кроки на основі аналізів')),
    );
  }

  void _notifyReminder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Скоро можна буде підключити нагадування.')),
    );
  }

  void _addTemplateStep({required String title, required String description, required ActionTimeframe timeframe}) {
    context.read<AppState>().addPlanItem(
          ActionItem(title: title, description: description, timeframe: timeframe),
        );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Додано «$title»')));
  }

  DateTime _dateForTimeframe(ActionTimeframe timeframe) {
    final now = DateTime.now();
    switch (timeframe) {
      case ActionTimeframe.now:
        return DateUtils.dateOnly(now);
      case ActionTimeframe.soon:
        return DateUtils.dateOnly(now.add(const Duration(days: 7)));
      case ActionTimeframe.later:
        return DateUtils.dateOnly(now.add(const Duration(days: 60)));
    }
  }

  Future<void> _showQuickNoteDialog(DateTime date) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Нотатка на ${date.day}.${date.month}.${date.year}'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Наприклад, записатися до ендокринолога'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Скасувати')),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                Navigator.of(context).pop(text);
              },
              child: const Text('Зберегти'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (note != null && note.isNotEmpty) {
      context.read<AppState>().addPlanNote(date, note);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Нотатку додано.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<AppState>().plan;
    final sortedPlan = [...plan]..sort((a, b) => a.timeframe.index.compareTo(b.timeframe.index));
    final sections = [
      _TimelineSectionData(
        timeframe: ActionTimeframe.now,
        title: 'Цього тижня',
        description: 'Кроки, що повертають енергію найближчими днями.',
        items: plan.where((item) => item.timeframe == ActionTimeframe.now).toList(),
      ),
      _TimelineSectionData(
        timeframe: ActionTimeframe.soon,
        title: 'Наступного тижня',
        description: 'Організаційні задачі та записи до лікарів.',
        items: plan.where((item) => item.timeframe == ActionTimeframe.soon).toList(),
      ),
      _TimelineSectionData(
        timeframe: ActionTimeframe.later,
        title: 'Через 2–3 місяці',
        description: 'Перевіримо динаміку й скоригуємо план.',
        items: plan.where((item) => item.timeframe == ActionTimeframe.later).toList(),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        MedlySectionCard(
          title: 'Мої дії сьогодні',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FilledButton.icon(
                onPressed: _addManualStep,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Додати крок'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(height: 16),
              SegmentedButton<PlanViewMode>(
                style: SegmentedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  side: BorderSide.none,
                  textStyle: Theme.of(context).textTheme.bodySmall,
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  selectedForegroundColor: const Color(0xFF8BA7FF),
                ),
                segments: _modeSegments,
                selected: {_viewMode},
                onSelectionChanged: (value) => setState(() => _viewMode = value.first),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_viewMode == PlanViewMode.timeline)
          ...sections.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final data = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: index == sections.length - 1 ? 12 : 32),
                child: _TimelineSection(
                  data: data,
                  isLast: index == sections.length - 1,
                  completed: _completed,
                  onToggleComplete: _toggleComplete,
                ),
              );
            },
          )
        else if (_viewMode == PlanViewMode.checklist)
          _ChecklistView(
            items: sortedPlan,
            completed: _completed,
            onToggleComplete: _toggleComplete,
          )
        else
          _CompactSections(
            data: sections,
            completed: _completed,
            onToggleComplete: _toggleComplete,
            onAddNote: (timeframe) => _showQuickNoteDialog(_dateForTimeframe(timeframe)),
            onShowReminder: _notifyReminder,
          ),
      ],
    );
  }
}

class _TimelineSectionData {
  const _TimelineSectionData({
    required this.timeframe,
    required this.title,
    required this.description,
    required this.items,
  });

  final ActionTimeframe timeframe;
  final String title;
  final String description;
  final List<ActionItem> items;
}

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({
    required this.data,
    required this.isLast,
    required this.completed,
    required this.onToggleComplete,
  });

  final _TimelineSectionData data;
  final bool isLast;
  final Set<String> completed;
  final ValueChanged<ActionItem> onToggleComplete;

  Color _colorFor(ActionTimeframe timeframe) {
    switch (timeframe) {
      case ActionTimeframe.now:
        return AppTheme.success;
      case ActionTimeframe.soon:
        return AppTheme.secondary;
      case ActionTimeframe.later:
        return AppTheme.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(data.timeframe);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast ? Colors.transparent : AppTheme.panel,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(data.description, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),
                if (data.items.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.panel,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Додай крок для цього періоду, щоб нічого не випадало з фокусу.',
                        style: Theme.of(context).textTheme.bodyMedium),
                  )
                else
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: data.items
                        .map(
                          (item) => _TimelineChip(
                            item: item,
                            color: color,
                            isCompleted: completed.contains('${item.title}|${item.description}'),
                            onToggleComplete: onToggleComplete,
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineChip extends StatelessWidget {
  const _TimelineChip({
    required this.item,
    required this.color,
    required this.isCompleted,
    required this.onToggleComplete,
  });

  final ActionItem item;
  final Color color;
  final bool isCompleted;
  final ValueChanged<ActionItem> onToggleComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isCompleted ? color.withOpacity(.18) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      constraints: const BoxConstraints(minWidth: 220),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              backgroundColor: isCompleted ? color : color.withOpacity(.12),
            ),
            onPressed: () => onToggleComplete(item),
            icon: Icon(
              isCompleted ? Icons.check : Icons.check_circle_outline,
              color: isCompleted ? Colors.white : color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistView extends StatelessWidget {
  const _ChecklistView({required this.items, required this.completed, required this.onToggleComplete});

  final List<ActionItem> items;
  final Set<String> completed;
  final ValueChanged<ActionItem> onToggleComplete;

  Color _colorFor(ActionTimeframe timeframe) {
    switch (timeframe) {
      case ActionTimeframe.now:
        return AppTheme.success;
      case ActionTimeframe.soon:
        return AppTheme.secondary;
      case ActionTimeframe.later:
        return AppTheme.warning;
    }
  }

  String _labelFor(ActionTimeframe timeframe) {
    switch (timeframe) {
      case ActionTimeframe.now:
        return 'Цього тижня';
      case ActionTimeframe.soon:
        return 'Наступного тижня';
      case ActionTimeframe.later:
        return 'Через 2–3 місяці';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.panel,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('Додай кроки, і я складу список задач із термінами.', style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    return Column(
      children: items.map((item) {
        final key = '${item.title}|${item.description}';
        final isDone = completed.contains(key);
        final color = _colorFor(item.timeframe);
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(.2)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(.03), blurRadius: 12, offset: const Offset(0, 8)),
            ],
          ),
          child: Row(
            children: [
              Checkbox(
                activeColor: color,
                value: isDone,
                onChanged: (_) => onToggleComplete(item),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(decoration: isDone ? TextDecoration.lineThrough : null),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: color.withOpacity(.15), borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        _labelFor(item.timeframe),
                        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(item.description, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.textMuted),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _CompactSections extends StatelessWidget {
  const _CompactSections({
    required this.data,
    required this.completed,
    required this.onToggleComplete,
    required this.onAddNote,
    required this.onShowReminder,
  });

  final List<_TimelineSectionData> data;
  final Set<String> completed;
  final ValueChanged<ActionItem> onToggleComplete;
  final ValueChanged<ActionTimeframe> onAddNote;
  final VoidCallback onShowReminder;

  String _dateLabelFor(ActionTimeframe timeframe) {
    final now = DateTime.now();
    late DateTime date;
    switch (timeframe) {
      case ActionTimeframe.now:
        date = now;
        break;
      case ActionTimeframe.soon:
        date = now.add(const Duration(days: 7));
        break;
      case ActionTimeframe.later:
        date = now.add(const Duration(days: 60));
        break;
    }
    return '${date.day}.${date.month}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: data.map((section) {
        final color = switch (section.timeframe) {
          ActionTimeframe.now => AppTheme.success,
          ActionTimeframe.soon => AppTheme.secondary,
          ActionTimeframe.later => AppTheme.warning,
        };
        final displayItems = section.items.take(3).toList();
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: MedlySectionCard(
            title: section.title,
            subtitle: 'До ${_dateLabelFor(section.timeframe)}',
            action: IconButton(
              tooltip: 'Додати нотатку',
              icon: const Icon(Icons.note_add_outlined),
              onPressed: () => onAddNote(section.timeframe),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(.15),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: color, size: 16),
                          const SizedBox(width: 6),
                          Text(_dateLabelFor(section.timeframe),
                              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.notifications_none, size: 18),
                      color: AppTheme.textMuted,
                      onPressed: onShowReminder,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (displayItems.isEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Додай хоча б один крок, щоб бачити план для цього періоду.',
                        style: Theme.of(context).textTheme.bodyMedium),
                  )
                else
                  ...displayItems.map((item) {
                    final key = '${item.title}|${item.description}';
                    final isDone = completed.contains(key);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Checkbox(
                        activeColor: color,
                        value: isDone,
                        onChanged: (_) => onToggleComplete(item),
                      ),
                      title: Text(
                        item.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(decoration: isDone ? TextDecoration.lineThrough : null),
                      ),
                      subtitle: Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_note_outlined),
                        onPressed: () => onAddNote(section.timeframe),
                      ),
                    );
                  }),
                if (section.items.length > displayItems.length)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '+${section.items.length - displayItems.length} ще',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

List<ActionItem> _planItemsForDate(List<ActionItem> plan, DateTime date) {
  final today = DateUtils.dateOnly(DateTime.now());
  final diff = date.difference(today).inDays;
  ActionTimeframe timeframe;
  if (diff <= 7) {
    timeframe = ActionTimeframe.now;
  } else if (diff <= 21) {
    timeframe = ActionTimeframe.soon;
  } else {
    timeframe = ActionTimeframe.later;
  }
  return plan.where((item) => item.timeframe == timeframe).toList();
}
final List<ButtonSegment<PlanViewMode>> _modeSegments = [
  ButtonSegment(
    value: PlanViewMode.timeline,
    label: Text('Шкала'),
    icon: Icon(Icons.timeline, size: 16, color: Color(0xFF8BA7FF)),
  ),
  ButtonSegment(
    value: PlanViewMode.checklist,
    label: Text('Список'),
    icon: Icon(Icons.checklist_rtl, size: 16, color: Color(0xFF8BA7FF)),
  ),
  ButtonSegment(
    value: PlanViewMode.compact,
    label: Text('Фокус'),
    icon: Icon(Icons.center_focus_strong, size: 16, color: Color(0xFF8BA7FF)),
  ),
];
