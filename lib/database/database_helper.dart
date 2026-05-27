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
      version: 2, // Versão atualizada para criar a nova tabela
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

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
    
    // Tabela de inventário
    await db.execute('''
      CREATE TABLE inventory (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT NOT NULL,
        value INTEGER NOT NULL,
        quantity INTEGER NOT NULL
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Se estava na versão 1, cria a tabela de inventário
      await db.execute('''
        CREATE TABLE inventory (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          type TEXT NOT NULL,
          icon TEXT NOT NULL,
          value INTEGER NOT NULL,
          quantity INTEGER NOT NULL
        )
      ''');
    }
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

  // --- MÉTODOS DO INVENTÁRIO ---
  
  Future<void> saveItem(Map<String, dynamic> itemMap) async {
    final db = await instance.database;
    final id = itemMap['id'];
    
    // Tenta atualizar se já existe, senão insere
    int count = await db.update('inventory', itemMap, where: 'id = ?', whereArgs: [id]);
    if (count == 0) {
      await db.insert('inventory', itemMap);
    }
  }

  Future<void> deleteItem(String id) async {
    final db = await instance.database;
    await db.delete('inventory', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> loadInventory() async {
    final db = await instance.database;
    return await db.query('inventory');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
