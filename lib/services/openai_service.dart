import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:medly_app/models/ai_insight.dart';
import 'package:medly_app/models/chat_message.dart';
import 'package:medly_app/models/lab_marker.dart';
import 'package:medly_app/models/onboarding_answers.dart';

class OpenAIService {
  OpenAIService({http.Client? client, String? apiKey})
      : _client = client ?? http.Client(),
        _apiKey = apiKey ?? const String.fromEnvironment('OPENAI_API_KEY');

  final http.Client _client;
  final String _apiKey;
  static const _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const _model = 'gpt-4o-mini';

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<AIInsight?> analyzeMarkers({
    required OnboardingAnswers answers,
    required List<LabMarker> markers,
  }) async {
    if (!isConfigured) return null;

    final prompt = StringBuffer()
      ..writeln('Ти — Medly, турботливий асистент-лікар.')
      ..writeln('Мета — пояснити аналізи простими словами, українською.')
      ..writeln('Користувач: ${answers.age} років, гендер ${answers.gender},')
      ..writeln('фокус: ${answers.goal}, стиль життя: ${answers.lifestyle}.')
      ..writeln('Маркери:');
    for (final marker in markers) {
      prompt.writeln('${marker.name}: ${marker.value} ${marker.unit} (реф. ${marker.reference})');
    }
    prompt
      ..writeln('Сформуй JSON {"overview": "...","markers":[{"name":"","status":"","summary":""}]}')
      ..writeln('Статус — коротке означення (\"Нижче норми\", \"В межах\" тощо).')
      ..writeln('Summary: кілька речень + дії з емодзі, українською.');

    final body = {
      'model': _model,
      'temperature': 0.3,
      'messages': [
        {
          'role': 'system',
          'content': 'Ти Medly — турботливий асистент, говори просто й з емпатією.',
        },
        {
          'role': 'user',
          'content': prompt.toString(),
        },
      ],
    };

    final response = await _client.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode >= 400) {
      throw Exception('OpenAI error: ${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = ((data['choices'] as List).first as Map<String, dynamic>)['message']['content'] as String;
    final jsonStart = content.indexOf('{');
    final jsonEnd = content.lastIndexOf('}');
    if (jsonStart == -1 || jsonEnd == -1) {
      throw Exception('Invalid AI payload');
    }
    final insightJson = jsonDecode(content.substring(jsonStart, jsonEnd + 1)) as Map<String, dynamic>;
    return AIInsight.fromJson(insightJson);
  }

  Future<String> chatResponse({
    required String prompt,
    required List<ChatMessage> history,
    required OnboardingAnswers answers,
  }) async {
    if (!isConfigured) {
      return 'Зараз працюємо в демо-режимі. Додайте ключ OpenAI, щоб отримати розширені відповіді.';
    }
    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content': 'Ти Medly — теплий лікар-друг, відповідай українською, структуровано і з емодзі.',
      },
      {
        'role': 'user',
        'content':
            'Контекст: ${answers.age} років, гендер ${answers.gender}, фокус ${answers.goal}, стиль ${answers.lifestyle}.',
      },
    ];
    for (final message in history.takeLast(6)) {
      messages.add({
        'role': message.sender == ChatSender.user ? 'user' : 'assistant',
        'content': message.content,
      });
    }
    messages.add({'role': 'user', 'content': prompt});

    final response = await _client.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'model': _model, 'messages': messages, 'temperature': 0.4}),
    );
    if (response.statusCode >= 400) {
      throw Exception('OpenAI error: ${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ((data['choices'] as List).first as Map<String, dynamic>)['message']['content'] as String;
  }

  void dispose() => _client.close();
}

extension on List<ChatMessage> {
  Iterable<ChatMessage> takeLast(int count) sync* {
    final start = length - count;
    for (var i = start < 0 ? 0 : start; i < length; i++) {
      yield this[i];
    }
  }
}
