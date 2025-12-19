import 'package:flutter/material.dart';
import 'package:medly_app/controllers/app_state.dart';
import 'package:medly_app/theme/app_theme.dart';
import 'package:medly_app/widgets/faq_accordion.dart';
import 'package:medly_app/widgets/medly_section_card.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLogin = false;
  String _value = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final method = state.registrationMethod;
    final isPhone = method == RegistrationMethod.phone;
    final hint = isPhone ? '+380 ХХ ХХ ХХ ХХ' : 'name@email.com';
    final isValid = _value.trim().isNotEmpty &&
        (isPhone ? _value.replaceAll(RegExp(r'[^0-9+]'), '').length >= 10 : _value.contains('@'));

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;
            final theme = Theme.of(context);

              const preferenceCopy = 'Як тобі зручніше?';
              final registrationCard = MedlySectionCard(
                title: _isLogin ? 'Увійти' : 'Зареєструватися',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment<bool>(value: false, label: Text('Зареєстрація')),
                      ButtonSegment<bool>(value: true, label: Text('Вхід')),
                    ],
                    selected: {_isLogin},
                    onSelectionChanged: (selection) => setState(() => _isLogin = selection.first),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      preferenceCopy,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      children: [
                        ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: AppTheme.panel,
                                child: Icon(Icons.phone_android, size: 16, color: AppTheme.primary),
                              ),
                              SizedBox(width: 8),
                              Text('Телефон'),
                            ],
                          ),
                          selected: isPhone,
                          onSelected: (_) => _onMethodChanged(context, RegistrationMethod.phone),
                        ),
                        ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: AppTheme.panel,
                                child: Icon(Icons.alternate_email, size: 16, color: AppTheme.primary),
                              ),
                              SizedBox(width: 8),
                              Text('Email'),
                            ],
                          ),
                          selected: !isPhone,
                          onSelected: (_) => _onMethodChanged(context, RegistrationMethod.email),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    keyboardType: isPhone ? TextInputType.phone : TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: hint,
                      labelText: isPhone ? 'Номер телефону' : 'Email',
                    ),
                    onChanged: (value) => setState(() => _value = value.trim()),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: isValid ? () => _submit(state) : null,
                    icon: Icon(_isLogin ? Icons.login : Icons.verified_user),
                    label: Text(_isLogin ? 'Увійти' : 'Зареєструватися'),
                  ),
                ],
              ),
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWide ? 1080 : 640),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            color: Colors.white,
                          border: Border.all(color: AppTheme.panel),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.05),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome, color: AppTheme.primary),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                'Привіт! Я Medly, твій медичний друг.',
                                style: theme.textTheme.titleLarge?.copyWith(color: AppTheme.textPrimary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton.filledTonal(
                              onPressed: () => _openFaqSheet(context),
                              style: IconButton.styleFrom(backgroundColor: AppTheme.surface),
                              icon: const Icon(Icons.help_outline, color: AppTheme.primary),
                            ),
                          ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                          child: registrationCard,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onMethodChanged(BuildContext context, RegistrationMethod method) {
    context.read<AppState>().setRegistrationMethod(method);
    setState(() {
      _value = '';
      _controller.clear();
    });
  }

  void _submit(AppState state) {
    state.registerContact(_value);
    FocusScope.of(context).unfocus();
  }

  void _openFaqSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: .75,
          maxChildSize: .9,
          minChildSize: .5,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.help_center_outlined, color: AppTheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Питання та відповіді',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: const FaqAccordion(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
