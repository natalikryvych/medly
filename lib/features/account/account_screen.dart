import 'package:flutter/material.dart';
import 'package:medly_app/controllers/app_state.dart';
import 'package:medly_app/theme/app_theme.dart';
import 'package:medly_app/widgets/medly_section_card.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _notificationsEnabled = true;
  bool _aiTipsEnabled = true;
  bool _autoSync = true;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Мій акаунт')),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.background, AppTheme.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            MedlySectionCard(
              title: 'Контакт і доступ',
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.account_circle_outlined),
                    title: const Text('Контакт для входу'),
                    subtitle: Text(state.contact.isEmpty ? 'Додай email або телефон' : state.contact),
                    trailing: TextButton(
                      onPressed: () => _showEditContact(context),
                      child: const Text('Змінити'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Доступ до даних'),
                    subtitle: const Text('Medly зберігає результати лише для тебе.'),
                    trailing: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Налаштування безпеки буде додано незабаром.')),
                        );
                      },
                      child: const Text('FAQ'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            MedlySectionCard(
              title: 'Персоналізація',
              subtitle: 'Обери, як Medly буде нагадувати тобі про здоров’я.',
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _notificationsEnabled,
                    title: const Text('Нагадування про аналізи'),
                    subtitle: const Text('Надсилати push-сповіщення про повторні тести та лікування'),
                    onChanged: (value) => setState(() => _notificationsEnabled = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _aiTipsEnabled,
                    title: const Text('AI-поради в чаті'),
                    subtitle: const Text('Дозволити Medly пропонувати додаткові кроки в діалозі'),
                    onChanged: (value) => setState(() => _aiTipsEnabled = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _autoSync,
                    title: const Text('Автосинхронізація лабораторій'),
                    subtitle: const Text('Зберігати всі завантажені результати в профілі'),
                    onChanged: (value) => setState(() => _autoSync = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            MedlySectionCard(
              title: 'Поширені питання',
              child: Column(
                children: const [
                  _FaqRow(question: 'Як Medly обробляє мої дані?', answer: 'Ми зберігаємо їх локально та шифруємо в хмарі.'),
                  Divider(height: 24),
                  _FaqRow(question: 'Чи можна підключити лабораторію автоматично?', answer: 'Так, інтеграції з’являться у v2.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                context.read<AppState>().logout();
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Вийти з профілю'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditContact(BuildContext context) async {
    final state = context.read<AppState>();
    final controller = TextEditingController(text: state.contact);
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Оновити контакт'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Введи email або телефон'),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Скасувати')),
            FilledButton(
              onPressed: () {
                state.registerContact(controller.text.trim());
                Navigator.of(ctx).pop();
              },
              child: const Text('Зберегти'),
            ),
          ],
        );
      },
    );
  }
}

class _FaqRow extends StatelessWidget {
  const _FaqRow({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(answer, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
