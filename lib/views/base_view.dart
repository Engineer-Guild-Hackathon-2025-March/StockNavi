import 'package:flutter/material.dart';
import 'package:stocknavi/models/consumable.dart';
import 'package:stocknavi/views/table_view.dart';
import 'package:stocknavi/controllers/controller.dart';

class BaseView extends StatefulWidget {
  const BaseView({super.key});

  @override
  State<BaseView> createState() => BaseViewState();
}

class BaseViewState extends State<BaseView> {
  late final ConsumableTable _table;
  List<Consumable> _consumables = [];
  Controller? _controller;

  void setController(Controller controller) {
    _controller = controller;
    _table = ConsumableTable(controller: controller);
  }

  void updateTable(List<Consumable> consumables) {
    setState(() {
      _consumables = consumables;
    });
  }

  void showNotification(List<Consumable> items) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${items.length}個のアイテムが残り少なくなっています')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Stock Navi')),
      body: SingleChildScrollView(
        child: Column(
          children: [_table.build(context, _consumables), _buildAddItemForm()],
        ),
      ),
    );
  }

  Widget _buildAddItemForm() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '商品名'),
            ),
            TextFormField(
              controller: amountController,
              decoration: const InputDecoration(labelText: '容量'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () {
                if (_controller != null &&
                    nameController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  try {
                    _controller!.handleUserInput('add', {
                      'name': nameController.text,
                      'amount': double.tryParse(amountController.text) ?? 0.0,
                      'tags': <String>[],
                      'dailyConsumption': 0.0,
                    });
                    nameController.clear();
                    amountController.clear();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('入力内容を確認してください')),
                    );
                  }
                }
              },
              child: const Text('追加'),
            ),
          ],
        ),
      ),
    );
  }
}
