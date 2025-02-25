class Consumption {
  final int id;
  final String name;
  final int mAverageId;
  final double daysLeft;
  final double amount;
  final double? dailyConsumption;
  final int usagePerDay;
  final int numberOfUsers;
  final DateTime createdAt;
  final DateTime updatedAt;

  Consumption({
    required this.id,
    required this.name,
    required this.mAverageId,
    required this.daysLeft,
    required this.amount,
    this.dailyConsumption,
    required this.usagePerDay,
    required this.numberOfUsers,
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
      'usage_per_day': usagePerDay,
      'number_of_users': numberOfUsers,
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
      usagePerDay: map['usage_per_day'],
      numberOfUsers: map['number_of_users'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
