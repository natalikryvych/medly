class OnboardingAnswers {
  const OnboardingAnswers({
    required this.age,
    required this.gender,
    required this.goal,
    required this.lifestyle,
    required this.diet,
    required this.weight,
    required this.height,
  });

  final int age;
  final String gender;
  final String goal;
  final String lifestyle;
  final String diet;
  final int weight;
  final int height;

  bool get isComplete =>
      age > 0 &&
      gender.isNotEmpty &&
      goal.isNotEmpty &&
      lifestyle.isNotEmpty &&
      diet.isNotEmpty &&
      weight > 0 &&
      height > 0;

  OnboardingAnswers copyWith({
    int? age,
    String? gender,
    String? goal,
    String? lifestyle,
    String? diet,
    int? weight,
    int? height,
  }) {
    return OnboardingAnswers(
      age: age ?? this.age,
      gender: gender ?? this.gender,
      goal: goal ?? this.goal,
      lifestyle: lifestyle ?? this.lifestyle,
      diet: diet ?? this.diet,
      weight: weight ?? this.weight,
      height: height ?? this.height,
    );
  }

  static const empty = OnboardingAnswers(age: 0, gender: '', goal: '', lifestyle: '', diet: '', weight: 0, height: 0);
}
