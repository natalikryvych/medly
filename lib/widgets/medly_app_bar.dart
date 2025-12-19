import 'package:flutter/material.dart';
import 'package:medly_app/controllers/app_state.dart';
import 'package:medly_app/features/account/account_screen.dart';
import 'package:provider/provider.dart';

class MedlyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MedlyAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final defaultActions = [
      IconButton(
        tooltip: 'Налаштування сповіщень',
        icon: const Icon(Icons.notifications_outlined),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Нагадування з’являться тут зовсім скоро.')),
          );
        },
      ),
      IconButton(
        tooltip: 'Мій акаунт',
        icon: const Icon(Icons.account_circle_outlined),
        onPressed: state.isRegistered
            ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AccountScreen()))
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Спершу зареєструйся, щоб керувати профілем.')),
                );
              },
      ),
    ];

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Medly',
            style: theme.textTheme.titleMedium!.copyWith(
              letterSpacing: 2,
              color: theme.colorScheme.primary,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      actions: [
        ...?actions,
        ...defaultActions,
      ],
    );
  }
}
