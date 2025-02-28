import 'package:stocknavi/models/consumption.dart';
import 'package:stocknavi/database/database_helper.dart';

class Consumable {
  double amount;
  String name;
  List<String> tags;
  double? dailyConsumption;
  double daysLeft;
  int usagePerDay;
  int numberOfUsers;
  DateTime createdAt;
  DateTime updatedAt;
  double initialAmount;

  Consumable({
    required this.amount,
    required this.name,
    required this.tags,
    this.dailyConsumption,
    this.daysLeft = 0,
    required this.usagePerDay,
    required this.numberOfUsers,
    required this.createdAt,
    required this.updatedAt,
    required this.initialAmount,
  });

  void calculateAmount() {
    final elapsedDays = DateTime.now().difference(updatedAt);
    final resAmount =
        amount -
        (dailyConsumption ?? 0) *
            usagePerDay *
            numberOfUsers *
            (elapsedDays.inHours / 24);
    amount = double.parse(resAmount.toStringAsFixed(2));
  }

  void calculateDaysLeft() {
    if (dailyConsumption != null && dailyConsumption! > 0) {
      daysLeft = amount / (dailyConsumption! * usagePerDay * numberOfUsers);
    }
  }

  factory Consumable.fromConsumption(Consumption consumption) {
    return Consumable(
      amount: consumption.amount,
      name: consumption.name,
      tags: [],
      dailyConsumption: consumption.dailyConsumption,
      daysLeft: consumption.daysLeft,
      usagePerDay: consumption.usagePerDay,
      numberOfUsers: consumption.numberOfUsers,
      createdAt: consumption.createdAt,
      updatedAt: consumption.updatedAt,
      initialAmount: consumption.initialAmount,
    );
  }

  static Future<Consumable> fromConsumptionWithTags(
    Consumption consumption,
  ) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'm_average',
      where: 'id = ?',
      whereArgs: [consumption.mAverageId],
    );

    List<String> tags = [];
    double? dailyConsumption;
    if (maps.isNotEmpty) {
      tags = [maps.first['tag'] as String];
      dailyConsumption = maps.first['average_consumption'] as double?;
    }

    return Consumable(
      amount: consumption.amount,
      name: consumption.name,
      tags: tags,
      dailyConsumption: dailyConsumption,
      daysLeft: consumption.daysLeft,
      usagePerDay: consumption.usagePerDay,
      numberOfUsers: consumption.numberOfUsers,
      createdAt: consumption.createdAt,
      updatedAt: consumption.updatedAt,
      initialAmount: consumption.initialAmount,
    );
  }

  Consumption toConsumption({required int mAverageId}) {
    return Consumption(
      id: 0,
      name: name,
      mAverageId: mAverageId,
      daysLeft: daysLeft,
      amount: amount,
      dailyConsumption: dailyConsumption,
      usagePerDay: usagePerDay,
      numberOfUsers: numberOfUsers,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      initialAmount: initialAmount,
    );
  }
}
