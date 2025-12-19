import 'package:medly_app/models/action_item.dart';
import 'package:medly_app/models/chat_message.dart';
import 'package:medly_app/models/lab_marker.dart';

class MockData {
  static List<LabMarker> labMarkers() {
    return [
      LabMarker(
        name: 'Гемоглобін',
        value: '115',
        unit: 'g/L',
        reference: '120 - 160',
        status: MarkerStatus.low,
      ),
      LabMarker(
        name: 'Феритин',
        value: '24',
        unit: 'ng/mL',
        reference: '15 - 150',
        status: MarkerStatus.low,
      ),
      LabMarker(
        name: 'ТТГ',
        value: '3.2',
        unit: 'μIU/mL',
        reference: '0.3 - 4.5',
        status: MarkerStatus.normal,
      ),
      LabMarker(
        name: 'Вітамін D',
        value: '26',
        unit: 'ng/mL',
        reference: '30 - 100',
        status: MarkerStatus.low,
      ),
      LabMarker(
        name: 'Загальний холестерин',
        value: '5.4',
        unit: 'mmol/L',
        reference: '< 5.0',
        status: MarkerStatus.high,
      ),
    ];
  }

  static List<ActionItem> plan() {
    return const [
      ActionItem(
        title: 'Щодня приймай вітамін D3',
        description:
            'Прийми 2000 МО разом із продуктами, де вже є корисні жири — лосось, яйця, тост з авокадо чи жменька горіхів. Так відчуватимеш «сонце» навіть у похмурі дні.',
        timeframe: ActionTimeframe.now,
      ),
      ActionItem(
        title: 'Заплануй зустріч з сімейним лікарем',
        description: 'Постав нагадування і поділися з лікарем аналізами та тим, як ти почуваєшся. Нехай профі допоможе підлаштувати маршрут.',
        timeframe: ActionTimeframe.soon,
      ),
      ActionItem(
        title: 'Повтори панель заліза та вітаміну D',
        description: 'Через 2–3 місяці здаємо феритин, гемоглобін і вітамін D ще раз, щоб побачити, як тіло реагує на нові звички.',
        timeframe: ActionTimeframe.later,
      ),
      ActionItem(
        title: 'Підсили меню продуктами з залізом',
        description: 'Змішуй страви з червоного м’яса, квасолі, гречки й зелені. Додай щось з вітаміном C — лимон чи перець — і залізо засвоїться швидше.',
        timeframe: ActionTimeframe.now,
      ),
    ];
  }

  static List<ChatMessage> seedChat() {
    return [
      ChatMessage(
        sender: ChatSender.ai,
        content: 'Привіт! Я Medly. Допоможу розібратись з аналізами — про що поговоримо?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ChatMessage(
        sender: ChatSender.user,
        content: 'Як швидко може піднятися гемоглобін, якщо почати добавки?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
      ChatMessage(
        sender: ChatSender.ai,
        content:
            'За щоденного прийому заліза з вітаміном C поліпшення видно за 4–6 тижнів. Енергія повертається ще раніше.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
    ];
  }

  static Map<String, String> explanation() {
    return {
      'overview': 'Загалом результати виглядають добре! Є кілька показників, яким варто приділити увагу для більшої енергії.',
      'Гемоглобін':
          'Гемоглобін переносить кисень. Легке зниження може давати втому й відчуття холоду. Часто це наслідок дефіциту заліза чи рясних менструацій.',
      'Феритин':
          'Феритин — запас заліза. Коли резерви низькі, організм не має ресурсу для вироблення гемоглобіну.',
      'Вітамін D':
          'Вітамін D підтримує імунітет, гормони та настрій. Рівень нижче 30 нг/мл часто проявляється виснаженістю.',
      'Загальний холестерин':
          'Холестерин трохи підвищений. Додавай більше клітковини, омега-3 і регулярний рух, щоб підтримати баланс ліпідів.',
    };
  }
}
