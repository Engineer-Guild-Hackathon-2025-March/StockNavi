import 'package:flutter/material.dart';
import 'package:stocknavi/models/consumable.dart';
import 'package:stocknavi/views/edit_dialog.dart';
import 'package:stocknavi/views/edit_item_page.dart';
import 'package:stocknavi/controllers/controller.dart';

class ConsumableTable {
  final Controller controller;

  ConsumableTable({required this.controller});

  Widget build(BuildContext context, List<Consumable> consumables) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('商品名')),
          DataColumn(label: Text('残量')),
          DataColumn(label: Text('残り日数')),
          DataColumn(label: Text('操作')),
        ],
        rows:
            consumables.map((consumable) {
              return DataRow(
                cells: [
                  DataCell(Text(consumable.name)),
                  DataCell(Text('${consumable.amount}ml')),
                  DataCell(Text('${consumable.daysLeft.toStringAsFixed(1)}日')),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
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
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            controller.handleUserInput('delete', {
                              'name': consumable.name,
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.shopping_cart),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => EditDialog(
                                    consumable: consumable,
                                    controller: controller,
                                    isPurchase: true,
                                  ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }
}
