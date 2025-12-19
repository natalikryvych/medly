import 'package:flutter/material.dart';
import 'package:medly_app/data/mock_data.dart';
import 'package:medly_app/models/action_item.dart';
import 'package:medly_app/models/chat_message.dart';
import 'package:medly_app/models/lab_marker.dart';
import 'package:medly_app/models/onboarding_answers.dart';
import 'package:medly_app/services/openai_service.dart';

enum RegistrationMethod { phone, email }

class AppState extends ChangeNotifier {
  AppState({OpenAIService? aiService})
      : _answers = OnboardingAnswers.empty,
        _markers = MockData.labMarkers(),
        _plan = MockData.plan(),
        _chat = MockData.seedChat(),
        _aiService = aiService {
    final initial = Map<String, String>.from(MockData.explanation());
    _overview = initial.remove('overview') ?? '';
    _explanation = initial;
  }

  OnboardingAnswers _answers;
  List<LabMarker> _markers;
  List<ActionItem> _plan;
  List<ChatMessage> _chat;
  Map<String, String> _explanation = const {};
  String _overview = '';
  OpenAIService? _aiService;
  bool _isGenerating = false;
  String? _aiError;
  RegistrationMethod _registrationMethod = RegistrationMethod.phone;
  String _contact = '';
  final Map<DateTime, List<String>> _planNotes = {};

  OnboardingAnswers get answers => _answers;
  List<LabMarker> get markers => List.unmodifiable(_markers);
  List<ActionItem> get plan => List.unmodifiable(_plan);
  List<ChatMessage> get chat => List.unmodifiable(_chat);
  Map<String, String> get explanation => _explanation;
  String get overview => _overview;
  bool get isGeneratingInsight => _isGenerating;
  String? get aiError => _aiError;
  OpenAIService get _service => _aiService ??= OpenAIService();
  bool get hasLiveAI => _service.isConfigured;
  RegistrationMethod get registrationMethod => _registrationMethod;
  String get contact => _contact;
  bool get isRegistered => _contact.isNotEmpty;
  Map<DateTime, List<String>> get planNotes =>
      _planNotes.map((key, value) => MapEntry(key, List.unmodifiable(value)));

  void updateOnboarding({
    int? age,
    String? gender,
    String? goal,
    String? lifestyle,
    String? diet,
    int? weight,
    int? height,
  }) {
    _answers = _answers.copyWith(
      age: age,
      gender: gender,
      goal: goal,
      lifestyle: lifestyle,
      diet: diet,
      weight: weight,
      height: height,
    );
    notifyListeners();
  }

  void overrideAnswers(OnboardingAnswers answers) {
    _answers = answers;
    notifyListeners();
  }

  void updateMarker(int index, LabMarker marker) {
    _markers[index] = marker;
    notifyListeners();
  }

  void addMarker(LabMarker marker) {
    _markers = [..._markers, marker];
    notifyListeners();
  }

  void addPlanItem(ActionItem item) {
    _plan = [..._plan, item];
    notifyListeners();
  }

  void addPlanItems(List<ActionItem> items) {
    if (items.isEmpty) return;
    _plan = [..._plan, ...items];
    notifyListeners();
  }

  void addPlanNote(DateTime date, String note) {
    final day = DateUtils.dateOnly(date);
    final notes = List<String>.from(_planNotes[day] ?? []);
    notes.add(note);
    _planNotes[day] = notes;
    notifyListeners();
  }

  Future<void> mockPdfImport() async {
    // Simulate parsing time
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _markers = MockData.labMarkers();
    notifyListeners();
  }

  Future<void> mockPhotoImport() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _markers = MockData.labMarkers();
    notifyListeners();
  }

  void setRegistrationMethod(RegistrationMethod method) {
    if (_registrationMethod == method) return;
    _registrationMethod = method;
    notifyListeners();
  }

  void registerContact(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    _contact = trimmed;
    notifyListeners();
  }

  void logout() {
    _contact = '';
    notifyListeners();
  }

  Future<void> refreshAiExplanation() async {
    final service = _service;
    if (!service.isConfigured) {
      _aiError = 'Додайте OPENAI_API_KEY через --dart-define для живого аналізу.';
      notifyListeners();
      return;
    }
    _isGenerating = true;
    _aiError = null;
    notifyListeners();
    try {
      final insight = await service.analyzeMarkers(answers: _answers, markers: _markers);
      if (insight != null) {
        _overview = insight.overview;
        _explanation = {
          for (final marker in insight.markers) marker.name: '${marker.status}\n${marker.summary}',
        };
      }
    } catch (error) {
      _aiError = 'Не вдалося отримати відповідь AI: $error';
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  Future<void> sendChat(String text) async {
    if (text.trim().isEmpty) return;
    final service = _service;
    final now = DateTime.now();
    _chat = [
      ..._chat,
      ChatMessage(sender: ChatSender.user, content: text.trim(), timestamp: now),
    ];
    notifyListeners();

    try {
      final response = await service.chatResponse(
        prompt: text.trim(),
        history: _chat,
        answers: _answers,
      );
      _chat = [
        ..._chat,
        ChatMessage(sender: ChatSender.ai, content: response, timestamp: DateTime.now()),
      ];
    } catch (error) {
      _chat = [
        ..._chat,
        ChatMessage(
          sender: ChatSender.ai,
          content: 'Поки що не можу відповісти. Помилка: $error',
          timestamp: DateTime.now(),
        ),
      ];
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _aiService?.dispose();
    super.dispose();
  }
}
