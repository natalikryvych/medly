import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medly_app/controllers/app_state.dart';
import 'package:medly_app/features/auth/auth_screen.dart';
import 'package:medly_app/features/home/home_shell.dart';
import 'package:medly_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

class MedlyApp extends StatelessWidget {
  const MedlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Medly',
        theme: AppTheme.light,
        builder: (context, child) {
          final textScale = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.1);
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: textScale),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (!state.isRegistered) {
          return const AuthScreen();
        }
        return const HomeShell();
      },
    );
  }
}
