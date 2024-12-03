import 'package:hedieaty/models/event.dart';
import 'package:hedieaty/models/gift.dart';
import 'package:hedieaty/models/user.dart';
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
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      firestoreId TEXT UNIQUE,
      username TEXT NOT NULL UNIQUE,
      email TEXT NOT NULL UNIQUE,
      profileImage TEXT,
      eventsCount INTEGER NOT NULL DEFAULT 0,
      lastModified DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
  ''');

    await db.execute('''
    CREATE TABLE events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL,
      firestoreId TEXT UNIQUE,
      name TEXT NOT NULL,
      date TEXT NOT NULL,
      time TEXT NOT NULL,
      location TEXT NOT NULL,
      description TEXT NOT NULL,
      status TEXT CHECK(status IN ('upcoming', 'current', 'past')) NOT NULL DEFAULT 'upcoming',
      isDeleted BOOLEAN NOT NULL DEFAULT FALSE,
      lastModified DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (userId) REFERENCES users(id)
    );
  ''');
    await db.execute('''
    CREATE TABLE gifts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      eventId INTEGER NOT NULL,
      firestoreId TEXT UNIQUE,
      name TEXT NOT NULL,
      price REAL NOT NULL,
      description TEXT NOT NULL,
      category TEXT NOT NULL,
      giftImageUrl TEXT,
      status TEXT CHECK(status IN ('unpledged', 'purchased', 'pledged')) NOT NULL DEFAULT 'unpledged',
      pledgedBy INTEGER,
      isDeleted BOOLEAN NOT NULL DEFAULT FALSE,
      lastModified DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (eventId) REFERENCES events(id),
      FOREIGN KEY (pledgedBy) REFERENCES users(id)
    );
  ''');
  }

  Future<int> insertUser(UserModel user) async {
    Database db = await database;
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<int> updateUser(UserModel user) async {
    Database db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
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

  Future<List<Map<String, dynamic>>> getFriendOfUser(String id) async {
    Database db = await database;
    return await db.query(
      'users',
      where: 'firestoreId != ?',
      whereArgs: [id],
    );
  }

  Future<int> insertEvent(EventModel event) async {
    Database db = await database;
    return await db.insert('events', event.toMap(),
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

  Future<int> updateEvent(EventModel event) async {
    Database db = await database;
    return await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<int> deleteEvent(EventModel event) async {
    Database db = await database;
    return await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<int> insertGift(GiftModel gift) async {
    Database db = await database;
    return await db.insert('gifts', gift.toMap(),
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

  Future<int> updateGift(GiftModel gift) async {
    Database db = await database;
    return await db.update(
      'gifts',
      gift.toMap(),
      where: 'id = ?',
      whereArgs: [gift.id],
    );
  }

  Future<int> deleteGift(GiftModel gift) async {
    Database db = await database;
    return await db.delete(
      'gifts',
      where: 'id = ?',
      whereArgs: [gift.id],
    );
  }
}
