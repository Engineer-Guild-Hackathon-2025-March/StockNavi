import 'package:flutter/material.dart';
import 'package:stocknavi/models/consumable.dart';
import 'package:stocknavi/controllers/controller.dart';

class EditDialog extends StatefulWidget {
  final Consumable consumable;
  final Controller controller;
  final bool isPurchase;

  const EditDialog({
    super.key,
    required this.consumable,
    required this.controller,
    this.isPurchase = false,
  });

  @override
  _EditDialogState createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  late TextEditingController _amountController;
  late TextEditingController _dailyConsumptionController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text:
          widget.isPurchase
              ? widget.consumable.amount
                  .toString() // 購入の場合はデフォルト容量
              : widget.consumable.amount.toString(),
    );
    _dailyConsumptionController = TextEditingController(
      text: widget.consumable.dailyConsumption?.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dailyConsumptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isPurchase ? '購入しました' : '商品情報の更新'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.consumable.name),
          SizedBox(height: 16),
          TextField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: widget.isPurchase ? '新しい容量 (ml)' : '現在の残量 (ml)',
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16),
          TextField(
            controller: _dailyConsumptionController,
            decoration: InputDecoration(labelText: '1日あたりの使用量 (ml)'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('キャンセル'),
        ),
        TextButton(
          onPressed: () {
            final newAmount =
                double.tryParse(_amountController.text) ??
                widget.consumable.amount;
            final newDailyConsumption =
                double.tryParse(_dailyConsumptionController.text) ??
                widget.consumable.dailyConsumption;

            widget.controller.handleUserInput('update', {
              'name': widget.consumable.name,
              'amount': newAmount,
              'tags': widget.consumable.tags,
              'dailyConsumption': newDailyConsumption,
            });

            Navigator.pop(context);
          },
          child: Text('保存'),
        ),
      ],
    );
  }
}
