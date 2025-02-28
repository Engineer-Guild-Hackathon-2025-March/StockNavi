import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('stocknavi.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE m_average (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tag TEXT NOT NULL,
        average_consumption REAL NOT NULL,
        unit TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE t_consumption (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        m_average_id INTEGER,
        days_left REAL NOT NULL,
        amount REAL NOT NULL,
        daily_consumption REAL,
        usage_per_day INTEGER NOT NULL,
        number_of_users INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        initial_amount REAL NOT NULL, 
        FOREIGN KEY (m_average_id) REFERENCES m_average (id)
      )
    ''');

    await _insertDefaultAverages(db);
  }

  Future<void> _insertDefaultAverages(Database db) async {
    final String response = await rootBundle.loadString(
      'default_averages.json',
    );
    final List<dynamic> data = json.decode(response);

    for (var average in data) {
      await db.insert('m_average', {
        'tag': average['tag'],
        'average_consumption': average['average_consumption'],
        'unit': average['unit'],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }
}
