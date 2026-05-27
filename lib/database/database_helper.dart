import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('game_2d.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Tabela de status do personagem
    await db.execute('''
      CREATE TABLE player_stats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        level INTEGER NOT NULL,
        currentExp INTEGER NOT NULL,
        maxExp INTEGER NOT NULL,
        currentHealth INTEGER NOT NULL,
        maxHealth INTEGER NOT NULL,
        attackPower INTEGER NOT NULL,
        defense INTEGER NOT NULL
      )
    ''');
  }

  Future<void> saveStats(Map<String, dynamic> statsMap) async {
    final db = await instance.database;
    // Tentar atualizar o primeiro registro, ou inserir se não existir
    int count = await db.update('player_stats', statsMap, where: 'id = ?', whereArgs: [1]);
    if (count == 0) {
      statsMap['id'] = 1;
      await db.insert('player_stats', statsMap);
    }
  }

  Future<Map<String, dynamic>?> loadStats() async {
    final db = await instance.database;
    final result = await db.query('player_stats', where: 'id = ?', whereArgs: [1]);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
