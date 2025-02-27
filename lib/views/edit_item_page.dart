import 'package:flutter/material.dart';
import 'package:stocknavi/models/consumable.dart';
import 'package:stocknavi/controllers/controller.dart';
import 'package:stocknavi/database/database_helper.dart';

class EditItemPage extends StatefulWidget {
  final Consumable consumable;
  final Controller controller;

  const EditItemPage({
    super.key,
    required this.consumable,
    required this.controller,
  });

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  late TextEditingController nameController;
  late TextEditingController amountController;
  late TextEditingController usagePerDayController;
  late TextEditingController numberOfUsersController;
  late String selectedTag;
  bool isPurchased = false;
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

  void _updateItem() {
    try {
      double amount;
      if (isPurchased) {
        final purchasedAmount = double.tryParse(amountController.text) ?? 0.0;
        amount = widget.consumable.amount + purchasedAmount;
      } else {
        amount =
            double.tryParse(amountController.text) ?? widget.consumable.amount;
      }

      widget.controller.handleUserInput('update', {
        'name': nameController.text,
        'tag': selectedTag,
        'tags': [selectedTag],
        'amount': amount,
        'usagePerDay': int.tryParse(usagePerDayController.text) ?? 1,
        'numberOfUsers': int.tryParse(numberOfUsersController.text) ?? 1,
        'dailyConsumption': widget.consumable.dailyConsumption,
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('更新に失敗しました。入力内容を確認してください')));
    }
  }

  void _deleteItem() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('確認'),
            content: Text('「${widget.consumable.name}」を削除しますか？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.controller.handleUserInput('delete', {
                    'name': widget.consumable.name,
                  });
                  Navigator.pop(context);
                },
                child: const Text('削除', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
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
        actions: [
          IconButton(
            onPressed: _deleteItem,
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('タグ', style: TextStyle(color: Colors.blue)),
              DropdownButtonFormField<String>(
                value: selectedTag,
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
              const Text('新しくストックを購入しましたか？'),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => isPurchased = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isPurchased ? Colors.blue : Colors.grey.shade300,
                      ),
                      child: const Text('購入した'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => isPurchased = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            !isPurchased ? Colors.blue : Colors.grey.shade300,
                      ),
                      child: const Text('未購入'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              isPurchased
                  ? _buildPurchasedAmountField()
                  : _buildRemainingAmountField(),

              const SizedBox(height: 16),

              const Text('1日の使用回数', style: TextStyle(color: Colors.blue)),
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
                  onPressed: _updateItem,
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
                    '更新する',
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

  Widget _buildPurchasedAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('購入量', style: TextStyle(color: Colors.blue)),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '購入した量',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(_currentUnit, style: const TextStyle(color: Colors.blue)),
            const SizedBox(width: 5),
            const Text('購入した', style: TextStyle(color: Colors.blue)),
          ],
        ),
      ],
    );
  }

  Widget _buildRemainingAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('現在の残量', style: TextStyle(color: Colors.blue)),
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
            Text(_currentUnit, style: const TextStyle(color: Colors.blue)),
          ],
        ),
      ],
    );
  }
}
