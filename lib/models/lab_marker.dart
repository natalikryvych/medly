class LabMarker {
  LabMarker({
    required this.name,
    required this.value,
    required this.unit,
    required this.reference,
    required this.status,
  });

  final String name;
  final String value;
  final String unit;
  final String reference;
  final MarkerStatus status;

  LabMarker copyWith({
    String? value,
    MarkerStatus? status,
  }) => LabMarker(
        name: name,
        value: value ?? this.value,
        unit: unit,
        reference: reference,
        status: status ?? this.status,
      );
}

enum MarkerStatus { low, normal, high }
