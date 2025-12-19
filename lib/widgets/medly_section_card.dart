import 'package:flutter/material.dart';
import 'package:medly_app/theme/app_theme.dart';

class MedlySectionCard extends StatelessWidget {
  const MedlySectionCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.action,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.primary.withOpacity(.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || action != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: theme.textTheme.headlineSmall,
                        ),
                      if (subtitle != null)
                        Text(subtitle!, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                if (action != null) action!,
              ],
            ),
          if ((title != null || action != null) && child is! SizedBox) const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
