import 'package:flutter/material.dart';

import '../controllers/controller.dart';
import '../database/database_helper.dart';
import '../models/consumable.dart';

class AddItemPage extends StatefulWidget {
  final Consumable consumable = Consumable(
    amount: 0,
    name: '',
    tags: [''],
    usagePerDay: 1,
    numberOfUsers: 1,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  final Controller controller;

  // consumable は任意引数。指定がなければ const Consumable(...) を使う
  AddItemPage({super.key, required this.controller});

  @override
  State<AddItemPage> createState() {
    return _AddItemPageState();
  }
}

class _AddItemPageState extends State<AddItemPage> {
  late TextEditingController nameController;
  late TextEditingController amountController;
  late TextEditingController usagePerDayController;
  late TextEditingController numberOfUsersController;
  late String selectedTag;
  List<String> _tags = [];
  Map<String, String> _tagUnitMap = {};
  String _currentUnit = 'ml';

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.consumable.name);
    amountController = TextEditingController(
      text: widget.consumable.amount.toString(),
    );
    usagePerDayController = TextEditingController(
      text: widget.consumable.usagePerDay.toString(),
    );
    numberOfUsersController = TextEditingController(
      text: widget.consumable.numberOfUsers.toString(),
    );
    selectedTag =
        widget.consumable.tags.isNotEmpty ? widget.consumable.tags.first : '';
    _loadTagsAndUnits();
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    usagePerDayController.dispose();
    numberOfUsersController.dispose();
    super.dispose();
  }

  Future<void> _loadTagsAndUnits() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('m_average');

    setState(() {
      _tags = [];
      _tagUnitMap = {};

      for (var map in maps) {
        final String tag = map['tag'] as String;
        final String unit = map['unit'] as String;

        _tags.add(tag);
        _tagUnitMap[tag] = unit;
      }

      if (!_tags.contains(selectedTag) && selectedTag.isNotEmpty) {
        _tags.add(selectedTag);
        _tagUnitMap[selectedTag] = 'ml';
      }

      _updateCurrentUnit();
    });
  }

  void _updateCurrentUnit() {
    if (_tagUnitMap.containsKey(selectedTag)) {
      _currentUnit = _tagUnitMap[selectedTag]!;
    } else {
      _currentUnit = 'ml';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stock Navi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade100,
        // actions: [
        //   IconButton(
        //     onPressed: _deleteItem,
        //     icon: const Icon(Icons.delete, color: Colors.red),
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('タグ', style: TextStyle(color: Colors.blue)),
              DropdownButtonFormField<String>(
                value:
                    (_tags.contains(selectedTag) && selectedTag.isNotEmpty)
                        ? selectedTag
                        : null,
                isExpanded: true,
                items:
                    _tags.map((tag) {
                      return DropdownMenuItem<String>(
                        value: tag,
                        child: Text(tag),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTag = value!;
                    _updateCurrentUnit();
                  });
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

              const Text('商品名', style: TextStyle(color: Colors.blue)),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: '商品名を入力',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              const Text('残量', style: TextStyle(color: Colors.blue)),
              Row(
                children: [
                  const Text('残り', style: TextStyle(color: Colors.blue)),
                  const SizedBox(width: 5),
                  Expanded(
                    child: TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '残量',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _currentUnit,
                    style: const TextStyle(color: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('1日の使用回数', style: const TextStyle(color: Colors.blue)),
              TextField(
                controller: usagePerDayController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

              const Text('使用人数', style: TextStyle(color: Colors.blue)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: numberOfUsersController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('人', style: TextStyle(color: Colors.blue)),
                ],
              ),

              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _insertItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    '追加する',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _insertItem() {
    try {
      widget.controller.handleUserInput('add', {
        'name': nameController.text,
        'tag': selectedTag,
        'amount': double.tryParse(amountController.text) ?? 0.0,
        'usagePerDay': int.tryParse(usagePerDayController.text) ?? 1,
        'numberOfUsers': int.tryParse(numberOfUsersController.text) ?? 1,
        'createdAt': widget.consumable.createdAt,
        'updatedAt': widget.consumable.updatedAt,
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('更新に失敗しました。入力内容を確認してください')));
    }
  }
}
