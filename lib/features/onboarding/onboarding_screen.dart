import 'package:flutter/material.dart';
import 'package:medly_app/controllers/app_state.dart';
import 'package:medly_app/models/onboarding_answers.dart';
import 'package:medly_app/theme/app_theme.dart';
import 'package:medly_app/widgets/medly_section_card.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final TextEditingController _ageController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;

  final goals = const [
    'Чекап здоров’я',
    'Вагітність',
    'Займаюся спортом',
    'Моніторю здоров’я',
    'Просто цікаво',
  ];
  final diets = const [
    'Збалансоване харчування',
    'Вегетаріанство',
    'Веганство',
    'Безглютенова дієта',
    'Інше',
  ];
  final activityLevels = const [
    'Сидячий спосіб життя',
    'Помірні тренування',
    'Активні тренування',
  ];
  final genders = const ['Жінка', 'Чоловік', 'Небінарна'];

  @override
  void initState() {
    super.initState();
    final answers = context.read<AppState>().answers;
    _ageController = TextEditingController(text: answers.age == 0 ? '' : answers.age.toString());
    _weightController = TextEditingController(text: answers.weight == 0 ? '' : answers.weight.toString());
    _heightController = TextEditingController(text: answers.height == 0 ? '' : answers.height.toString());
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final answers = state.answers;
    return DecoratedBox(
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
            title: 'Трішки контексту',
            subtitle: 'Пару питань про тебе — обіцяю, буде швидко :)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuestion(
                  title: 'Скільки тобі років?',
                  child: TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Наприклад, 32'),
                    onChanged: (value) {
                      final parsed = int.tryParse(value) ?? 0;
                      state.updateOnboarding(age: parsed);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                _buildQuestion(
                  title: 'Яка твоя вага?',
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: 'Наприклад, 62'),
                          onChanged: (value) {
                            final parsed = int.tryParse(value) ?? 0;
                            state.updateOnboarding(weight: parsed);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.primary.withOpacity(.1)),
                        ),
                        child: const Text('кг', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildQuestion(
                  title: 'Який твій зріст?',
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: 'Наприклад, 170'),
                          onChanged: (value) {
                            final parsed = int.tryParse(value) ?? 0;
                            state.updateOnboarding(height: parsed);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.primary.withOpacity(.1)),
                        ),
                        child: const Text('см', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildQuestion(
                  title: 'Стать',
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: genders
                        .map((option) => ChoiceChip(
                              label: Text(option),
                              selected: answers.gender == option,
                              onSelected: (_) => state.updateOnboarding(gender: option),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),
                _buildQuestion(
                  title: 'Яка твоя ціль?',
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: goals
                        .map((option) => FilterChip(
                              label: Text(option),
                              selected: answers.goal == option,
                              onSelected: (_) => state.updateOnboarding(goal: option),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),
                _buildQuestion(
                  title: 'Дієта',
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: diets
                        .map((option) => ChoiceChip(
                              label: Text(option),
                              selected: answers.diet == option,
                              onSelected: (_) => state.updateOnboarding(diet: option),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),
                _buildQuestion(
                  title: 'Спосіб життя',
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: activityLevels
                        .map((option) => ChoiceChip(
                              label: Text(option),
                              selected: answers.lifestyle == option,
                              onSelected: (_) => state.updateOnboarding(lifestyle: option),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (answers.isComplete) _PersonalizationSummary(answers: answers),
        ],
      ),
    );
  }

  Widget _buildQuestion({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

}

class _PersonalizationSummary extends StatelessWidget {
  const _PersonalizationSummary({required this.answers});

  final OnboardingAnswers answers;

  @override
  Widget build(BuildContext context) {
    final summary =
        '${answers.age} років · ${answers.gender} · ${answers.goal}\n${answers.diet}, ${answers.lifestyle}\n${answers.weight} кг · ${answers.height} см';
    return MedlySectionCard(
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.health_and_safety, color: AppTheme.primary),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Супер! Тепер завантаж аналізи',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  summary,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
