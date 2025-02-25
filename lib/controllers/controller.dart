import 'package:stocknavi/models/consumables_list.dart';
import 'package:stocknavi/views/base_view.dart';
import 'package:stocknavi/models/consumable.dart';
import 'package:stocknavi/services/notification_service.dart';
import 'package:stocknavi/database/database_helper.dart';

class Controller {
  final ConsumablesList _allConsumablesList = ConsumablesList();
  late final BaseViewState _view;
  final NotificationService _notificationService = NotificationService();

  Controller(BaseViewState view) {
    _view = view;
    _initializeData();
    _initializeNotifications();
  }

  Future<void> _initializeData() async {
    await _allConsumablesList.fetchAllConsumable();
    updateView();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initNotification();
    await _notificationService.scheduleWeeklyReminder();
  }

  Future<void> handleUserInput(String action, Map<String, dynamic> data) async {
    switch (action) {
      case 'add':
        final db = await DatabaseHelper.instance.database;
        final List<Map<String, dynamic>> maps = await db.query(
          'm_average',
          where: 'tag = ?',
          whereArgs: [data['tag']],
        );

        double? dailyConsumption;
        if (maps.isNotEmpty) {
          dailyConsumption = maps.first['average_consumption'] as double?;
        }

        final consumable = Consumable(
          name: data['name'],
          amount: data['amount'],
          tags: [data['tag']],
          dailyConsumption: dailyConsumption,
          usagePerDay: data['usagePerDay'],
          numberOfUsers: data['numberOfUsers'],
        );
        await _allConsumablesList.insertConsumable(consumable);
        break;
      case 'delete':
        await _allConsumablesList.deleteConsumable(data['name']);
        break;
      case 'update':
        final consumable = Consumable(
          name: data['name'],
          amount: data['amount'],
          tags: data['tags'] ?? [],
          dailyConsumption: data['dailyConsumption'],
          usagePerDay: data['usagePerDay'],
          numberOfUsers: data['numberOfUsers'],
        );
        consumable.calculateDaysLeft(); // 残り日数を再計算
        await _allConsumablesList.updateConsumable(consumable);
        break;
    }
    updateView();
  }

  void updateView() {
    _view.updateTable(_allConsumablesList.getConsumablesList());
    _checkRunningOutItems();
  }

  void pushNotice() {
    final noticeItems = _allConsumablesList.getNextNoticeConsumables();
    if (noticeItems.isNotEmpty) {
      _view.showNotification(noticeItems);
    }
  }

  void _checkRunningOutItems() {
    final runningOutItems =
        _allConsumablesList
            .getConsumablesList()
            .where((item) => item.daysLeft <= 7)
            .toList();

    /*for (var item in runningOutItems) {
      _notificationService.scheduleRunningOutNotification(
        item.name,
        item.daysLeft.toInt(),
      );
    }*/
  }

  // 手動で残量を更新するメソッド
  Future<void> updateAmount(String name, double newAmount) async {
    final items = _allConsumablesList.getConsumablesList();
    final itemIndex = items.indexWhere((item) => item.name == name);

    if (itemIndex != -1) {
      final item = items[itemIndex];
      await handleUserInput('update', {
        'name': name,
        'amount': newAmount,
        'tags': item.tags,
        'dailyConsumption': item.dailyConsumption,
        'usagePerDay': item.usagePerDay,
        'numberOfUsers': item.numberOfUsers,
      });
    }
  }

  // 商品を購入した時の処理
  Future<void> itemPurchased(String name, double fullAmount) async {
    final items = _allConsumablesList.getConsumablesList();
    final itemIndex = items.indexWhere((item) => item.name == name);

    if (itemIndex != -1) {
      final item = items[itemIndex];
      await handleUserInput('update', {
        'name': name,
        'amount': fullAmount,
        'tags': item.tags,
        'dailyConsumption': item.dailyConsumption,
        'usagePerDay': item.usagePerDay,
        'numberOfUsers': item.numberOfUsers,
      });
    }
  }

  // 消費量の予測値を更新する
  Future<void> updateDailyConsumption(
    String name,
    double newDailyConsumption,
  ) async {
    final items = _allConsumablesList.getConsumablesList();
    final itemIndex = items.indexWhere((item) => item.name == name);

    if (itemIndex != -1) {
      final item = items[itemIndex];
      await handleUserInput('update', {
        'name': name,
        'amount': item.amount,
        'tags': item.tags,
        'dailyConsumption': newDailyConsumption,
        'usagePerDay': item.usagePerDay,
        'numberOfUsers': item.numberOfUsers,
      });
    }
  }
}
