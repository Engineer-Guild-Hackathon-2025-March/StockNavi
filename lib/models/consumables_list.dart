import 'package:sqflite/sqflite.dart';
import 'package:stocknavi/database/database_helper.dart';
import 'package:stocknavi/models/consumable.dart';
import 'package:stocknavi/models/consumption.dart';

class ConsumablesList {
  List<Consumable> _consumablesList = [];

  Future<List<Consumable>> fetchAllConsumable() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('t_consumption');

    _consumablesList = await Future.wait(
      maps.map((map) async {
        final consumption = Consumption.fromMap(map);
        return await Consumable.fromConsumptionWithTags(consumption);
      }).toList(),
    );

    return _consumablesList;
  }

  Future<void> insertConsumable(
    Consumable consumable, {
    int mAverageId = 1,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final consumption = consumable.toConsumption(mAverageId: mAverageId);

    await db.insert(
      't_consumption',
      consumption.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await fetchAllConsumable();
  }

  Future<void> deleteConsumable(String name) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('t_consumption', where: 'name = ?', whereArgs: [name]);
    await fetchAllConsumable();
  }

  Future<void> updateConsumable(Consumable consumable) async {
    final db = await DatabaseHelper.instance.database;
    final consumption = consumable.toConsumption(mAverageId: 1);

    await db.update(
      't_consumption',
      consumption.toMap(),
      where: 'name = ?',
      whereArgs: [consumable.name],
    );

    await fetchAllConsumable();
  }

  List<Consumable> getNextNoticeConsumables() {
    return _consumablesList.where((item) => item.daysLeft <= 7).toList();
  }

  List<Consumable> getLatestNoticeConsumables() {
    return _consumablesList.where((item) => item.daysLeft <= 3).toList();
  }

  List<Consumable> getConsumablesList() => _consumablesList;
  void setConsumablesList(List<Consumable> list) => _consumablesList = list;
}
