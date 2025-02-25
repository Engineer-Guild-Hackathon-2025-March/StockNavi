import 'package:stocknavi/models/consumption.dart';

class Consumable {
  double amount;
  String name;
  List<String> tags;
  double? dailyConsumption;
  double daysLeft;

  Consumable({
    required this.amount,
    required this.name,
    required this.tags,
    this.dailyConsumption,
    this.daysLeft = 0,
  });

  double calculateAmount() {
    return amount - (dailyConsumption ?? 0);
  }

  void calculateDaysLeft() {
    if (dailyConsumption != null && dailyConsumption! > 0) {
      daysLeft = amount / dailyConsumption!;
    }
  }

  // ConsumptionモデルからConsumableを作成するファクトリメソッド
  factory Consumable.fromConsumption(Consumption consumption) {
    return Consumable(
      amount: consumption.amount,
      name: consumption.name,
      tags: [], // タグはm_averageから取得する必要があります
      dailyConsumption: consumption.dailyConsumption,
      daysLeft: consumption.daysLeft,
    );
  }

  // Consumptionモデルへの変換メソッド
  Consumption toConsumption({required int mAverageId}) {
    return Consumption(
      id: 0, // 新規作成時は0を指定
      name: name,
      mAverageId: mAverageId,
      daysLeft: daysLeft,
      amount: amount,
      dailyConsumption: dailyConsumption,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
