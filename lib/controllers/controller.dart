import 'dart:developer';
import 'dart:math' as Log;

import 'package:flutter/cupertino.dart';
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

  // タグに基づいてmAverageIdを取得するヘルパーメソッド
  Future<int> _getMaverageIdFromTag(String tag) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'm_average',
      where: 'tag = ?',
      whereArgs: [tag],
    );

    if (maps.isNotEmpty) {
      return maps.first['id'] as int;
    }
    return 1; // デフォルト値
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
        int? mAverageId;
        String? unit;
        if (maps.isNotEmpty) {
          dailyConsumption = maps.first['average_consumption'] as double?;
          mAverageId = maps.first['id'] as int?;
          unit = maps.first['unit'] as String?;
        }

        final consumable = Consumable(
          name: data['name'],
          amount: data['amount'],
          tags: [data['tag']],
          dailyConsumption: dailyConsumption,
          usagePerDay: data['usagePerDay'],
          numberOfUsers: data['numberOfUsers'],
          createdAt: data['createdAt'],
          updatedAt: data['updatedAt'],
        );

        // 残り日数を計算
        consumable.calculateDaysLeft();

        await _allConsumablesList.insertConsumable(
          consumable,
          mAverageId: mAverageId ?? 1,
        );
        break;
      case 'delete':
        await _allConsumablesList.deleteConsumable(data['name']);
        break;
      case 'update':
        // タグからmAverageIdを取得
        int mAverageId = 1;
        if (data['tags'] != null && (data['tags'] as List).isNotEmpty) {
          mAverageId = await _getMaverageIdFromTag(
            (data['tags'] as List<String>)[0],
          );
        }

        final consumable = Consumable(
          name: data['name'],
          amount: data['amount'],
          tags: data['tags'] ?? [],
          dailyConsumption: data['dailyConsumption'],
          usagePerDay: data['usagePerDay'],
          numberOfUsers: data['numberOfUsers'],
          createdAt: data['createdAt'],
          updatedAt: data['updatedAt'],
        );
        consumable.calculateAmount(); //残り容量を再計算
        consumable.calculateDaysLeft(); // 残り日数を再計算
        consumable.updatedAt = DateTime.now();
        await _allConsumablesList.updateConsumable(
          consumable,
          mAverageId: mAverageId,
        );
        break;
      case 'insert':
        int mAverageId = 1;
        if (data['tags'] != null && (data['tags'] as List).isNotEmpty) {
          mAverageId = await _getMaverageIdFromTag(
            (data['tags'] as List<String>)[0],
          );
        }

        final consumable = Consumable(
          name: data['name'],
          amount: data['amount'],
          tags: data['tags'] ?? [],
          dailyConsumption: data['dailyConsumption'],
          usagePerDay: data['usagePerDay'],
          numberOfUsers: data['numberOfUsers'],
          createdAt: data['createdAt'],
          updatedAt: data['updatedAt'],
        );
        consumable.fetchDefaultDailyConsumption(mAverageId);
        consumable.calculateDaysLeft();
        debugPrint("hello");
        await _allConsumablesList.insertConsumable(
          consumable,
          mAverageId: mAverageId,
        );
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
        'createdAt': item.createdAt,
        'updatedAt': item.updatedAt,
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
        'createdAt': item.createdAt,
        'updatedAt': item.updatedAt,
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
        'createdAt': item.createdAt,
        'updatedAt': item.updatedAt,
      });
    }
  }
}
