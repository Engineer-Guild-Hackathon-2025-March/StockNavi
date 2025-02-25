class Average {
  final int id;
  final String tag;
  final double averageConsumption;
  final String unit;
  final DateTime createdAt;
  final DateTime updatedAt;

  Average({
    required this.id,
    required this.tag,
    required this.averageConsumption,
    required this.unit,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tag': tag,
      'average_consumption': averageConsumption,
      'unit': unit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Average.fromMap(Map<String, dynamic> map) {
    return Average(
      id: map['id'],
      tag: map['tag'],
      averageConsumption: map['average_consumption'],
      unit: map['unit'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
