import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medly_app/app.dart';
import 'package:medly_app/controllers/app_state.dart';
import 'package:medly_app/features/auth/auth_screen.dart';
import 'package:medly_app/widgets/medly_app_bar.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Medly app renders navigation shell', (tester) async {
    await tester.pumpWidget(const MedlyApp());
    expect(find.byType(AuthScreen), findsOneWidget);
    final context = tester.element(find.byType(AuthScreen));
    Provider.of<AppState>(context, listen: false).registerContact('test@medly.app');
    await tester.pumpAndSettle();
    expect(find.byType(MedlyAppBar), findsOneWidget);
    await tester.tap(find.text('Аналізи'));
    await tester.pumpAndSettle();
  });
}
