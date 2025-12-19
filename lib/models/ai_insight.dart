class AIInsight {
  AIInsight({required this.overview, required this.markers});

  final String overview;
  final List<MarkerInsight> markers;

  factory AIInsight.fromJson(Map<String, dynamic> json) {
    final markerList = (json['markers'] as List<dynamic>? ?? [])
        .map((item) => MarkerInsight.fromJson(item as Map<String, dynamic>))
        .toList();
    return AIInsight(
      overview: json['overview'] as String? ?? '',
      markers: markerList,
    );
  }
}

class MarkerInsight {
  MarkerInsight({required this.name, required this.status, required this.summary});

  final String name;
  final String status;
  final String summary;

  factory MarkerInsight.fromJson(Map<String, dynamic> json) {
    return MarkerInsight(
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
    );
  }
}
