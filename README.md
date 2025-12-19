# Medly – Personal Health Companion

Medly is a concept Flutter application that showcases a "doctor in your pocket" experience. It personalizes onboarding, ingests lab results flexibly, explains biomarkers in plain language, lets people chat with an AI guide, and turns data into an actionable plan.

## Project structure
```
lib/
 ├─ app.dart, main.dart
 ├─ controllers/        → shared state (onboarding answers, markers, chat)
 ├─ data/               → mock data feeding AI explanations + plan
 ├─ features/
 │   ├─ onboarding      → personalization flow (age, gender, goal, lifestyle)
 │   ├─ lab_upload      → OCR entry points + editable markers
 │   ├─ ai_explainer    → overview + per-marker insights
 │   ├─ chat            → Medly AI chat UI
 │   └─ next_steps      → action plan grouped by timeframe
 ├─ theme/              → brand colors + typography
 └─ widgets/            → shared components (app bar, etc.)
```

## Getting started
1. [Install Flutter](https://docs.flutter.dev/get-started/install) (3.19+ recommended).
2. From this folder run `flutter pub get`.
3. (Optional) Provide an OpenAI key for live insights:
   ```
   flutter run -d <device> --dart-define=OPENAI_API_KEY=sk-your-key
   ```
   Without the key Medly falls back to the built-in demo explanations.

## Feature highlights
- **Onboarding** now starts with a quick registration (phone or email) and asks three questions so AI має контекст.
- **Lab upload** showcases camera/PDF/manual entry cards plus editable recognized markers.
- **AI explanation** (українською) додає емпатичний огляд та конкретні дії, а з OpenAI ключем — генерує живі інсайти за вашими маркерами.
- **Chat** підтримує відчуття "лікаря в кишені" і звертається українською.
- **Next steps** breaks actions into "now", "soon", and "later" to avoid overwhelm.

## Testing
Run the included smoke test:
```
flutter test
```
