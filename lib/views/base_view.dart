import 'package:flutter/material.dart';
import 'package:stocknavi/models/consumable.dart';
import 'package:stocknavi/views/table_view.dart';
import 'package:stocknavi/controllers/controller.dart';
import 'package:stocknavi/database/database_helper.dart';

class BaseView extends StatefulWidget {
  const BaseView({super.key});

  @override
  State<BaseView> createState() => BaseViewState();
}

class BaseViewState extends State<BaseView> {
  late final ConsumableTable _table;
  List<Consumable> _consumables = [];
  Controller? _controller;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

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

  Future<void> _loadTags() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('m_average');
    setState(() {
      _tags = maps.map((map) => map['tag'] as String).toList();
    });
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
    final usagePerDayController = TextEditingController();
    final numberOfUsersController = TextEditingController();
    String? selectedTag;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '商品名'),
            ),
            DropdownButtonFormField<String>(
              value: selectedTag,
              items:
                  _tags.map((tag) {
                    return DropdownMenuItem<String>(
                      value: tag,
                      child: Text(tag),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTag = value;
                });
              },
              decoration: const InputDecoration(labelText: 'タグ'),
            ),
            TextFormField(
              controller: amountController,
              decoration: const InputDecoration(labelText: '容量'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: usagePerDayController,
              decoration: const InputDecoration(labelText: '1日の使用回数'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: numberOfUsersController,
              decoration: const InputDecoration(labelText: '使用人数'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () {
                if (_controller != null &&
                    nameController.text.isNotEmpty &&
                    selectedTag != null &&
                    amountController.text.isNotEmpty &&
                    usagePerDayController.text.isNotEmpty &&
                    numberOfUsersController.text.isNotEmpty) {
                  try {
                    _controller!.handleUserInput('add', {
                      'name': nameController.text,
                      'tag': selectedTag,
                      'amount': double.tryParse(amountController.text) ?? 0.0,
                      'usagePerDay':
                          int.tryParse(usagePerDayController.text) ?? 1,
                      'numberOfUsers':
                          int.tryParse(numberOfUsersController.text) ?? 1,
                    });
                    nameController.clear();
                    amountController.clear();
                    usagePerDayController.clear();
                    numberOfUsersController.clear();
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
