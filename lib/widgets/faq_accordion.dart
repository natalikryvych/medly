import 'package:flutter/material.dart';
import 'package:medly_app/theme/app_theme.dart';
import 'package:medly_app/widgets/medly_section_card.dart';

class FaqAccordion extends StatelessWidget {
  const FaqAccordion({super.key});

  @override
  Widget build(BuildContext context) {
    return MedlySectionCard(
      title: 'Часті питання',
      child: Column(
        children: const [
          _FaqItem(
            question: 'Як змінити контакт?',
            answer: 'У “Моєму акаунті” можеш оновити email або телефон за кілька секунд.',
          ),
          Divider(height: 16),
          _FaqItem(
            question: 'Чи захищені дані?',
            answer: 'Так, Medly шифрує результати та нікому їх не передає без твоєї згоди.',
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: _toggle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(widget.question, style: theme.textTheme.titleSmall),
                    const Spacer(),
                    Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: AppTheme.primary),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(widget.answer, style: theme.textTheme.bodyMedium),
                  ),
                  crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
