import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDB {
  static Database? _database;
  static const String _databaseName = 'hedieaty.db';
  static const int _databaseVersion = 1;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      firestoreId TEXT UNIQUE,
      username TEXT NOT NULL,
      mobileNumber TEXT NOT NULL,
      profileImage TEXT
      lastModified DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      ''');
    await db.execute('''
      CREATE TABLE events(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL,
      firestoreId TEXT UNIQUE,
      name TEXT NOT NULL,
      date TEXT NOT NULL,
      time TEXT NOT NULL,
      location TEXT NOT NULL,
      description TEXT NOT NULL,
      status TEXT CHECK(eventStatus IN ('upcoming', 'current', 'past')) NOT NULL DEFAULT 'upcoming',
      lastModified DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (userId) REFERENCES users(id)
      ''');
    await db.execute('''
      CREATE TABLE gifts(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      eventId INTEGER NOT NULL,
      firestoreId TEXT UNIQUE,
      name TEXT NOT NULL,
      price REAL NOT NULL,
      description TEXT NOT NULL,
      category TEXT NOT NULL,
      giftImageUrl TEXT,
      status TEXT CHECK(giftStatus IN ('unpledged', 'purchased', 'pledged')) NOT NULL DEFAULT 'unpledged',
      pledgedBy INTEGER,
      lastModified DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (eventId) REFERENCES events(id),
      FOREIGN KEY (pledgedBy) REFERENCES users(id)
      ''');
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.insert(
      'users',
      user,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [user['id']],
    );
  }

  Future<Map<String, dynamic>?> getUser(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getUserByFirestoreId(String firestoreId) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'firestoreId = ?',
      whereArgs: [firestoreId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    Database db = await database;
    return await db.query('users');
  }

  Future<int> insertEvent(Map<String, dynamic> event) async {
    Database db = await database;
    return await db.insert('events', event,
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<List<Map<String, dynamic>>> getEventsByUserIdAndStatus(
      int userId, String status) async {
    Database db = await database;
    return await db.query(
      'events',
      where: 'userId = ? AND status = ?',
      whereArgs: [userId, status],
    );
  }

  Future<int> updateEvent(Map<String, dynamic> event) async {
    Database db = await database;
    return await db.update(
      'events',
      event,
      where: 'id = ?',
      whereArgs: [event['id']],
    );
  }

  Future<int> deleteEvent(Map<String, dynamic> event) async {
    Database db = await database;
    return await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [event['id']],
    );
  }

  Future<int> insertGift(Map<String, dynamic> gift) async {
    Database db = await database;
    return await db.insert('gifts', gift,
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<List<Map<String, dynamic>>> getGiftsByEventIdAndStatus(
      int eventId, String status) async {
    Database db = await database;
    return await db.query(
      'gifts',
      where: 'eventId = ? AND status = ?',
      whereArgs: [eventId, status],
    );
  }

  Future<int> updateGift(Map<String, dynamic> gift) async {
    Database db = await database;
    return await db.update(
      'gifts',
      gift,
      where: 'id = ?',
      whereArgs: [gift['id']],
    );
  }

  Future<int> deleteGift(Map<String, dynamic> gift) async {
    Database db = await database;
    return await db.delete(
      'gifts',
      where: 'id = ?',
      whereArgs: [gift['id']],
    );
  }
}
