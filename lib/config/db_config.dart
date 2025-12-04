import 'package:comic_book_reader/models/comics.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
 
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'comics.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE comics(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            filePath TEXT NOT NULL,
            coverPath TEXT,
            format TEXT NOT NULL,
            currentPage INTEGER DEFAULT 0,
            totalPages INTEGER DEFAULT 0,
            addedAt TEXT NOT NULL,
            lastOpened TEXT
          )
        ''');
      },
    );
  }

  // Insert or update comic (upsert)
  Future<int> insertComic(Comic comic) async {
    final dbClient = await db;
    return await dbClient.insert(
      'comics',
      comic.toMap(), // convert Comic to Map
      conflictAlgorithm: ConflictAlgorithm.replace, // replaces if id exists
    );
  }

  // Get all comics
  Future<List<Comic>> getComics() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query('comics');
    return maps.map((map) => Comic.fromMap(map)).toList();
  }

  // Delete a comic by id
  Future<int> deleteComic(int id) async {
    final dbClient = await db;
    return await dbClient.delete('comics', where: 'id = ?', whereArgs: [id]);
  }

  // Optional: get comic by id
  Future<Comic?> getComic(int id) async {
    final dbClient = await db;
    final maps = await dbClient.query(
      'comics',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Comic.fromMap(maps.first);
    }
    return null;
  }
}
