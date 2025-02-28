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

  Consumable({
    required this.amount,
    required this.name,
    required this.tags,
    this.dailyConsumption,
    this.daysLeft = 0,
    required this.usagePerDay,
    required this.numberOfUsers,
  });

  double calculateAmount() {
    return amount - (dailyConsumption ?? 0) * usagePerDay * numberOfUsers;
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
    );
  }

  Future<void> fetchDefaultDailyConsumption(int id)async{
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'm_average',
      columns: ['amount'],
      where: 'id = ?',
      whereArgs: [id],
    );

    // result が空でなければ、最初の行の 'amount' を返す
    if (result.isNotEmpty) {
      // もし amount が int 型である場合
      dailyConsumption = result.first['amount'] as double;
    } else {
      // 見つからなかった場合は null を返す
      dailyConsumption = 5.0;
    }
  }
}
