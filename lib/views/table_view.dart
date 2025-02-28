import 'package:flutter/material.dart';
import 'package:stocknavi/models/consumable.dart';
import 'package:stocknavi/views/edit_item_page.dart';
import 'package:stocknavi/controllers/controller.dart';

class ConsumableTable {
  final Controller controller;

  ConsumableTable({required this.controller});

  Widget build(BuildContext context, List<Consumable> consumables) {
    consumables.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));

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
              columnSpacing: 30, // カラム間のスペース調整
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
                  label: Expanded(child: Text('', textAlign: TextAlign.center)),
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
                              '${consumable.daysLeft.toStringAsFixed(1)}日',
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
                                        ),
                                  ),
                                );
                              },
                            ),
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
