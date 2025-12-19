class ActionItem {
  const ActionItem({required this.title, required this.description, required this.timeframe});

  final String title;
  final String description;
  final ActionTimeframe timeframe;
}

enum ActionTimeframe { now, soon, later }
