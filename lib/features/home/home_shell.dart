import 'package:flutter/material.dart';
import 'package:medly_app/features/ai_explainer/ai_explainer_screen.dart';
import 'package:medly_app/features/chat/chat_screen.dart';
import 'package:medly_app/features/lab_upload/lab_upload_screen.dart';
import 'package:medly_app/features/next_steps/next_steps_screen.dart';
import 'package:medly_app/features/onboarding/onboarding_screen.dart';
import 'package:medly_app/widgets/medly_app_bar.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _pages = const [
    OnboardingScreen(),
    LabUploadScreen(),
    AIExplainerScreen(),
    ChatScreen(),
    NextStepsScreen(),
  ];

  final _titles = const [
    '',
    '',
    '',
    '',
    '',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: MedlyAppBar(title: _titles[_index]),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _pages[_index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        backgroundColor: theme.colorScheme.surface,
        indicatorColor: theme.colorScheme.primary.withOpacity(.2),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite), label: 'Профіль'),
          NavigationDestination(icon: Icon(Icons.cloud_upload_outlined), label: 'Аналізи'),
          NavigationDestination(icon: Icon(Icons.auto_graph_outlined), label: 'Результати'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Чат'),
          NavigationDestination(icon: Icon(Icons.flag_outlined), label: 'План дій'),
        ],
        onDestinationSelected: (value) => setState(() => _index = value),
      ),
    );
  }
}
