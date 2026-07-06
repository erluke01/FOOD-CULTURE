import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> get instance async {
    _db ??= await _open();
    return _db!;
  }

  static Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'wanderlist.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.executeBatch('''
      CREATE TABLE cities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        country TEXT,
        lat REAL,
        lng REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0
      );

      CREATE TABLE places (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id TEXT UNIQUE NOT NULL,
        city_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        name TEXT NOT NULL,
        address TEXT,
        category TEXT,
        tag TEXT,
        lat REAL,
        lng REAL,
        date_visited TEXT,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        created_by TEXT,
        FOREIGN KEY (city_id) REFERENCES cities(id)
      );

      CREATE TABLE ratings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id TEXT UNIQUE NOT NULL,
        place_id INTEGER NOT NULL,
        user TEXT NOT NULL,
        quality REAL,
        quantity REAL,
        price REAL,
        service REAL,
        cleanliness REAL,
        beauty REAL,
        cost REAL,
        updated_at TEXT NOT NULL,
        UNIQUE(place_id, user),
        FOREIGN KEY (place_id) REFERENCES places(id)
      );

      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user TEXT NOT NULL,
        place_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        UNIQUE(user, place_id),
        FOREIGN KEY (place_id) REFERENCES places(id)
      );

      CREATE INDEX idx_places_city ON places(city_id);
      CREATE INDEX idx_ratings_place ON ratings(place_id);
      CREATE INDEX idx_favorites_user ON favorites(user);
    ''');
  }
}

extension DatabaseBatch on Database {
  Future<void> executeBatch(String sql) async {
    final statements = sql
        .split(';')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    for (final stmt in statements) {
      await execute(stmt);
    }
  }
}
