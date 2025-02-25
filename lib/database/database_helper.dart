import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
        FOREIGN KEY (m_average_id) REFERENCES m_average (id)
      )
    ''');

    await _insertDefaultAverages(db);
  }

  Future<void> _insertDefaultAverages(Database db) async {
    final defaultAverages = [
      {'tag': 'シャンプー', 'average_consumption': 6.0, 'unit': 'ml'},
      {'tag': 'ボディウォッシュ', 'average_consumption': 6.0, 'unit': 'ml'},
      {'tag': '洗濯洗剤（粉末）', 'average_consumption': 14.0, 'unit': 'g'},
      {'tag': '洗濯洗剤（液体）', 'average_consumption': 7.0, 'unit': 'g'},
      {'tag': '柔軟剤', 'average_consumption': 8.5, 'unit': 'ml'},
      {'tag': '食器用洗剤', 'average_consumption': 8.0, 'unit': 'ml'},
      {'tag': 'トイレットペーパー', 'average_consumption': 320.0, 'unit': 'cm'},
      {'tag': '歯磨き粉', 'average_consumption': 2.0, 'unit': 'g'},
      {'tag': '化粧水', 'average_consumption': 4.0, 'unit': 'ml'},
      {'tag': 'テッシュ', 'average_consumption': 7.0, 'unit': '枚'},
    ];

    for (var average in defaultAverages) {
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
