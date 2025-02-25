class Consumption {
  final int id;
  final String name;
  final int mAverageId;
  final double daysLeft;
  final double amount;
  final double? dailyConsumption;
  final DateTime createdAt;
  final DateTime updatedAt;

  Consumption({
    required this.id,
    required this.name,
    required this.mAverageId,
    required this.daysLeft,
    required this.amount,
    this.dailyConsumption,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'm_average_id': mAverageId,
      'days_left': daysLeft,
      'amount': amount,
      'daily_consumption': dailyConsumption,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Consumption.fromMap(Map<String, dynamic> map) {
    return Consumption(
      id: map['id'],
      name: map['name'],
      mAverageId: map['m_average_id'],
      daysLeft: map['days_left'],
      amount: map['amount'],
      dailyConsumption: map['daily_consumption'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
