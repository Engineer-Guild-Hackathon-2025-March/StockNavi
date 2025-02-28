import 'package:flutter/material.dart';
import 'package:stocknavi/models/consumable.dart';
import 'package:stocknavi/views/edit_item_page.dart';
import 'package:stocknavi/controllers/controller.dart';

class ConsumableTable {
  final Controller controller;

  ConsumableTable({required this.controller});

  Widget build(BuildContext context, List<Consumable> consumables) {
    consumables.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));

    if (consumables.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'まだ何も消耗品を登録していません\n右下の+ボタンから登録してみましょう',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          DataTableTheme(
            data: DataTableThemeData(
              headingTextStyle: TextStyle(color: Colors.black, fontSize: 16),
              headingRowHeight: 40, // ヘッダー行の高さ
              dataRowMinHeight: 48, // データ行の最小高さ
            ),
            child: DataTable(
              columnSpacing: 10, // カラム間のスペース調整
              columns: [
                DataColumn(
                  label: Expanded(
                    child: Text('分類', textAlign: TextAlign.center),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text('残り日数', textAlign: TextAlign.center),
                  ),
                ),
                DataColumn(
                  label: Expanded(
                    child: Text('操作', textAlign: TextAlign.center),
                  ),
                ),
              ],
              rows:
                  consumables.map((consumable) {
                    return DataRow(
                      cells: [
                        DataCell(Center(child: Text(consumable.tags[0]))),
                        DataCell(
                          Center(
                            child: Text(
                              '${consumable.daysLeft.toStringAsFixed(0)}日',
                              style: TextStyle(
                                color:
                                    consumable.daysLeft <= 7
                                        ? Colors.red
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              Center(
                                child: IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => EditItemPage(
                                              consumable: consumable,
                                              controller: controller,
                                              fromPurchase: false,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Center(
                                child: IconButton(
                                  icon: Icon(Icons.shopping_cart),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => EditItemPage(
                                              consumable: consumable,
                                              controller: controller,
                                              fromPurchase: true,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
          Container(height: 60),
        ],
      ),
    );
  }
}
