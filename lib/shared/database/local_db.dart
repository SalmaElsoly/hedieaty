import 'package:hedieaty/models/event.dart';
import 'package:hedieaty/models/gift.dart';
import 'package:hedieaty/models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDB {
  static Database? _database;
  static const String _databaseName = 'hedieaty.db';
  static const int _databaseVersion = 1;

  // Database initialization
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate, onOpen: (db) async {
          await db.execute('PRAGMA foreign_keys = ON;');
        });
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
      FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
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
      pledgedBy TEXT,
      isDeleted BOOLEAN NOT NULL DEFAULT FALSE,
      lastModified DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (eventId) REFERENCES events(id) ON DELETE CASCADE
    );
  ''');
  }

  // User operations
  Future<int> insertUser(UserModel user) async {
    Database db = await database;
    int id = await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    return id;
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

  Future<UserModel?> getUser(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? UserModel.fromMap(results.first) : null;
  }

  Future<UserModel?> getUserByFirestoreId(String firestoreId) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'firestoreId = ?',
      whereArgs: [firestoreId],
    );
    return results.isNotEmpty ? UserModel.fromMap(results[0]) : null;
  }

  Future<List<UserModel>> getFriendOfUser(String id) async {
    Database db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'firestoreId != ?',
      whereArgs: [id],
    );
    return List.generate(results.length, (i) => UserModel.fromMap(results[i]));
  }

  Future<void> deleteAllUsers() async {
    Database db = await database;
    await db.rawDelete('DELETE FROM users');
  }

  // Event operations
  Future<int> insertEvent(EventModel event) async {
    Database db = await database;
    return await db.insert('events', event.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<EventModel> getEvent(int eventId)async{
    Database db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [eventId],
    );
    return EventModel.fromMap(results[0]);
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

  Future<int> deleteEventByFirestoreId(String firestoreId) async {
    Database db = await database;
    return await db.delete(
      'events',
      where: 'firestoreId = ?',
      whereArgs: [firestoreId],
    );
  }
  Future<int> deleteEventsByUserId(int userId) async {
    Database db = await database;
    return await db.delete(
      'events',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<List<EventModel>> getEventsByUserId(int userId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('events', where: 'userId = ?', whereArgs: [userId]);
    if (maps.isEmpty) {
      return [];
    }
    return List.generate(maps.length, (i) {
      return EventModel.fromMap(maps[i]);
    });
  }

  Future<List<EventModel>> getEventsByUserIdAndStatus(
      int userId, String status) async {
    Database db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'events',
      where: 'userId = ? AND status = ?',
      whereArgs: [userId, status],
    );
    return List.generate(results.length, (i) => EventModel.fromMap(results[i]));
  }

  Future<void> deleteAllEvents() async {
    Database db = await database;
    await db.rawDelete('DELETE FROM events');
  }

  // Gift operations
  Future<int> insertGift(GiftModel gift) async {
    Database db = await database;
    return await db.insert('gifts', gift.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort);
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

  Future<List<GiftModel>> getGiftsByEventId(
      int eventId) async {
    Database db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'gifts',
      where: 'eventId = ?',
      whereArgs: [eventId],
    );
    return List.generate(results.length, (i) => GiftModel.fromMap(results[i]));
  }

  Future<int> deleteGiftsByEventId(int eventId) async {
    Database db = await database;
    return await db.delete(
      'gifts',
      where: 'eventId = ?',
      whereArgs: [eventId],
    );
  }

  Future<void> deleteAllGifts() async {
    Database db = await database;
    await db.rawDelete('DELETE FROM gifts');
  }
}