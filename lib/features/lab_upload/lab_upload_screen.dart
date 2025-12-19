import 'package:flutter/material.dart';
import 'package:medly_app/controllers/app_state.dart';
import 'package:medly_app/models/lab_marker.dart';
import 'package:medly_app/theme/app_theme.dart';
import 'package:medly_app/widgets/medly_section_card.dart';
import 'package:provider/provider.dart';

class LabUploadScreen extends StatefulWidget {
  const LabUploadScreen({super.key});

  @override
  State<LabUploadScreen> createState() => _LabUploadScreenState();
}

class _LabUploadScreenState extends State<LabUploadScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final markers = context.watch<AppState>().markers;
    final visibleMarkers = markers.where((marker) {
      if (_query.isEmpty) return true;
      final name = marker.name.toLowerCase();
      return name.contains(_query.toLowerCase());
    }).toList();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        MedlySectionCard(
          title: 'Обирай зручний спосіб завантаження',
          subtitle: 'Зроби фото, кинь PDF або введи сам — будь-який спосіб ок.',
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _UploadTile(
                icon: Icons.camera_alt_outlined,
                title: 'Зробити фото',
                subtitle: 'Швидко розпізнаю бланк і підсвічу маркери',
                onTap: () => _simulatePhotoCapture(context),
              ),
              _UploadTile(
                icon: Icons.picture_as_pdf_outlined,
                title: 'Завантажити PDF',
                subtitle: 'Підтримую будь-яку лабораторію',
                onTap: () => _simulatePdfUpload(context),
              ),
              _UploadTile(
                icon: Icons.keyboard_alt_outlined,
                title: 'Ввести вручну',
                subtitle: 'Швидко додай відсутній показник',
                onTap: () => _promptAddMarker(context, initialName: _query),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text('Детально по показниках', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Пошук або додай новий показник',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            setState(() {
                              _query = '';
                              _searchController.clear();
                            });
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
                onChanged: (value) => setState(() => _query = value.trim()),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: () => _promptAddMarker(context),
              icon: const Icon(Icons.add),
              label: const Text('Додати'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (visibleMarkers.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                const Icon(Icons.search_off, size: 48, color: AppTheme.textMuted),
                const SizedBox(height: 12),
                Text(
                  'Нічого не знайдено. Додай цей показник вручну.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (_query.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => _promptAddMarker(context, initialName: _query),
                    child: Text('Додати "${_query}"'),
                  ),
                ],
              ],
            ),
          )
        else
          ...List.generate(visibleMarkers.length, (index) {
            final marker = visibleMarkers[index];
            final originalIndex = markers.indexOf(marker);
            return _LabMarkerCard(marker: marker, index: originalIndex);
          }),
      ],
    );
  }

  Future<void> _promptAddMarker(BuildContext context, {String initialName = ''}) async {
    final nameController = TextEditingController(text: initialName);
    final valueController = TextEditingController();
    final unitController = TextEditingController(text: 'ммоль/л');
    final referenceController = TextEditingController();

    final newMarker = await showDialog<LabMarker>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Новий показник'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Назва'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: valueController,
                  decoration: const InputDecoration(labelText: 'Значення'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(labelText: 'Одиниці виміру'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: referenceController,
                  decoration: const InputDecoration(labelText: 'Референс (наприклад 3.5 - 5.5)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Скасувати')),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final value = valueController.text.trim();
                if (name.isEmpty || value.isEmpty) return;
                final marker = LabMarker(
                  name: name,
                  value: value,
                  unit: unitController.text.trim().isEmpty ? '-' : unitController.text.trim(),
                  reference: referenceController.text.trim().isEmpty ? '-' : referenceController.text.trim(),
                  status: MarkerStatus.normal,
                );
                Navigator.of(context).pop(marker);
              },
              child: const Text('Зберегти'),
            ),
          ],
        );
      },
    );

    if (newMarker != null) {
      context.read<AppState>().addMarker(newMarker);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Додано показник ${newMarker.name}')),
      );
      setState(() {
        _query = '';
        _searchController.clear();
      });
    }
  }

  Future<void> _simulatePdfUpload(BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      const SnackBar(content: Text('Імпортую PDF...')),
    );
    await context.read<AppState>().mockPdfImport();
    scaffold.showSnackBar(
      const SnackBar(content: Text('Готово! Дані з PDF додані.')),
    );
  }

  Future<void> _simulatePhotoCapture(BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      const SnackBar(content: Text('Відкриваю камеру...')),
    );
    await context.read<AppState>().mockPhotoImport();
    scaffold.showSnackBar(
      const SnackBar(content: Text('Фото оброблено та показники додано.')),
    );
  }
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({required this.icon, required this.title, required this.subtitle, this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.panel,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppTheme.primary.withOpacity(.1)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 32, color: Theme.of(context).colorScheme.secondary),
                const SizedBox(height: 16),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LabMarkerCard extends StatelessWidget {
  const _LabMarkerCard({required this.marker, required this.index});

  final LabMarker marker;
  final int index;

  double? _parseNumber(String input) {
    final normalized = input.replaceAll(',', '.').trim();
    return double.tryParse(normalized);
  }

  MarkerStatus _deriveStatus(String updatedValue) {
    final value = _parseNumber(updatedValue);
    if (value == null) return marker.status;
    final reference = marker.reference.replaceAll(',', '.');
    final numberMatches = RegExp(r'-?\d*\.?\d+')
        .allMatches(reference)
        .map((match) => double.tryParse(match.group(0)!))
        .whereType<double>()
        .toList();

    if (reference.contains('<') && numberMatches.isNotEmpty) {
      final threshold = numberMatches.first;
      return value < threshold ? MarkerStatus.normal : MarkerStatus.high;
    }

    if (reference.contains('>') && numberMatches.isNotEmpty) {
      final threshold = numberMatches.first;
      return value >= threshold ? MarkerStatus.normal : MarkerStatus.low;
    }

    if (numberMatches.length >= 2) {
      final lower = numberMatches.first;
      final upper = numberMatches[1];
      if (value < lower) return MarkerStatus.low;
      if (value > upper) return MarkerStatus.high;
      return MarkerStatus.normal;
    }

    return marker.status;
  }

  Color _statusColor(MarkerStatus status, BuildContext context) {
    switch (status) {
      case MarkerStatus.low:
        return AppTheme.warning;
      case MarkerStatus.high:
        return AppTheme.error;
      case MarkerStatus.normal:
        return AppTheme.success;
    }
  }

  String _statusLabel(MarkerStatus status) {
    switch (status) {
      case MarkerStatus.low:
        return 'Нижче норми';
      case MarkerStatus.high:
        return 'Вище норми';
      case MarkerStatus.normal:
        return 'У межах норми';
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: marker.value);

    void commitValue(String input) {
      final trimmed = input.trim();
      if (trimmed.isEmpty) return;
      final newStatus = _deriveStatus(trimmed);
      final newMarker = marker.copyWith(value: trimmed, status: newStatus);
      context.read<AppState>().updateMarker(index, newMarker);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.panel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _statusColor(marker.status, context).withOpacity(.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _statusColor(marker.status, context).withOpacity(.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(_statusLabel(marker.status), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(marker.name, style: Theme.of(context).textTheme.titleMedium),
                Text('Норма ${marker.reference}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: marker.unit,
                isDense: true,
              ),
              textInputAction: TextInputAction.done,
              onTapOutside: (_) => commitValue(controller.text),
              onEditingComplete: () => commitValue(controller.text),
              onSubmitted: commitValue,
            ),
          ),
        ],
      ),
    );
  }
}
