import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'connectu.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        major TEXT,
        year TEXT,
        interests TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Profiles table
    await db.execute('''
      CREATE TABLE profiles (
        user_id INTEGER PRIMARY KEY,
        username TEXT UNIQUE NOT NULL,
        major TEXT,
        year_of_study TEXT,
        comfort_level TEXT,
        privacy_mode TEXT DEFAULT 'public',
        bio TEXT,
        profile_image TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Interests table
    await db.execute('''
      CREATE TABLE interests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL
      )
    ''');

    // User interests table
    await db.execute('''
      CREATE TABLE user_interests (
        user_id INTEGER,
        interest_id INTEGER,
        PRIMARY KEY (user_id, interest_id),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (interest_id) REFERENCES interests(id) ON DELETE CASCADE
      )
    ''');

    // Matches table
    await db.execute('''
      CREATE TABLE matches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user1_id INTEGER NOT NULL,
        user2_id INTEGER NOT NULL,
        match_score INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user1_id, user2_id),
        FOREIGN KEY (user1_id) REFERENCES users(id),
        FOREIGN KEY (user2_id) REFERENCES users(id)
      )
    ''');

    // Events table
    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        location TEXT,
        event_time DATETIME,
        created_by INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (created_by) REFERENCES users(id)
      )
    ''');

    // Event RSVPs table
    await db.execute('''
      CREATE TABLE event_rsvps (
        user_id INTEGER,
        event_id INTEGER,
        status TEXT DEFAULT 'going',
        PRIMARY KEY (user_id, event_id),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
      )
    ''');

    // Chats table
    await db.execute('''
      CREATE TABLE chats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user1_id INTEGER NOT NULL,
        user2_id INTEGER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user1_id, user2_id),
        FOREIGN KEY (user1_id) REFERENCES users(id),
        FOREIGN KEY (user2_id) REFERENCES users(id)
      )
    ''');

    // Messages table
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chat_id INTEGER NOT NULL,
        sender_id INTEGER NOT NULL,
        message_text TEXT,
        sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (chat_id) REFERENCES chats(id) ON DELETE CASCADE,
        FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Mood entries table
    await db.execute('''
      CREATE TABLE mood_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        mood TEXT NOT NULL,
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Moderation reports table
    await db.execute('''
      CREATE TABLE moderation_reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reporter_id INTEGER NOT NULL,
        reported_user_id INTEGER NOT NULL,
        reason TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (reporter_id) REFERENCES users(id),
        FOREIGN KEY (reported_user_id) REFERENCES users(id)
      )
    ''');
  }

  // User operations
  Future<int> insertUser(String email, String passwordHash) async {
    final db = await database;
    return await db.insert('users', {
      'email': email,
      'password': passwordHash,
    });
  }

  Future<Map<String, dynamic>?> getUser(int userId) async {
    final db = await database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query('users', where: 'email = ?', whereArgs: [email]);
    return result.isNotEmpty ? result.first : null;
  }

  // Profile operations
  Future<int> insertProfile(Map<String, dynamic> profile) async {
    final db = await database;
    return await db.insert('profiles', profile);
  }

  Future<Map<String, dynamic>?> getProfile(int userId) async {
    final db = await database;
    final result = await db.query('profiles', where: 'user_id = ?', whereArgs: [userId]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateProfile(Map<String, dynamic> profile) async {
    final db = await database;
    return await db.update('profiles', profile, where: 'user_id = ?', whereArgs: [profile['user_id']]);
  }

  // Interest operations
  Future<int> insertInterest(String name) async {
    final db = await database;
    return await db.insert('interests', {'name': name});
  }

  Future<List<Map<String, dynamic>>> getAllInterests() async {
    final db = await database;
    return await db.query('interests');
  }

  // User interests operations
  Future<int> addUserInterest(int userId, int interestId) async {
    final db = await database;
    return await db.insert('user_interests', {
      'user_id': userId,
      'interest_id': interestId,
    });
  }

  Future<List<Map<String, dynamic>>> getUserInterests(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT i.* FROM interests i
      JOIN user_interests ui ON i.id = ui.interest_id
      WHERE ui.user_id = ?
    ''', [userId]);
  }

  Future<int> removeUserInterest(int userId, int interestId) async {
    final db = await database;
    return await db.delete('user_interests',
        where: 'user_id = ? AND interest_id = ?', whereArgs: [userId, interestId]);
  }

  // Match operations
  Future<int> insertMatch(int user1Id, int user2Id, int matchScore) async {
    final db = await database;
    return await db.insert('matches', {
      'user1_id': user1Id,
      'user2_id': user2Id,
      'match_score': matchScore,
    });
  }

  Future<List<Map<String, dynamic>>> getUserMatches(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT * FROM matches WHERE user1_id = ? OR user2_id = ?
    ''', [userId, userId]);
  }

  // Event operations
  Future<int> insertEvent(Map<String, dynamic> event) async {
    final db = await database;
    return await db.insert('events', event);
  }

  Future<List<Map<String, dynamic>>> getAllEvents() async {
    final db = await database;
    return await db.query('events', orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getEvent(int eventId) async {
    final db = await database;
    final result = await db.query('events', where: 'id = ?', whereArgs: [eventId]);
    return result.isNotEmpty ? result.first : null;
  }

  // Event RSVP operations
  Future<int> insertEventRsvp(int userId, int eventId, String status) async {
    final db = await database;
    return await db.insert('event_rsvps', {
      'user_id': userId,
      'event_id': eventId,
      'status': status,
    });
  }

  Future<List<Map<String, dynamic>>> getEventRsvps(int eventId) async {
    final db = await database;
    return await db.query('event_rsvps', where: 'event_id = ?', whereArgs: [eventId]);
  }

  // Chat operations
  Future<int> insertChat(int user1Id, int user2Id) async {
    final db = await database;
    return await db.insert('chats', {
      'user1_id': user1Id,
      'user2_id': user2Id,
    });
  }

  Future<List<Map<String, dynamic>>> getUserChats(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT * FROM chats WHERE user1_id = ? OR user2_id = ?
    ''', [userId, userId]);
  }

  // Message operations
  Future<int> insertMessage(int chatId, int senderId, String messageText) async {
    final db = await database;
    return await db.insert('messages', {
      'chat_id': chatId,
      'sender_id': senderId,
      'message_text': messageText,
    });
  }

  Future<List<Map<String, dynamic>>> getChatMessages(int chatId) async {
    final db = await database;
    return await db.query('messages', where: 'chat_id = ?', whereArgs: [chatId], orderBy: 'sent_at ASC');
  }

  // Mood entry operations
  Future<int> insertMoodEntry(int userId, String mood, String? notes) async {
    final db = await database;
    return await db.insert('mood_entries', {
      'user_id': userId,
      'mood': mood,
      'notes': notes,
    });
  }

  Future<List<Map<String, dynamic>>> getUserMoodEntries(int userId) async {
    final db = await database;
    return await db.query('mood_entries', where: 'user_id = ?', whereArgs: [userId], orderBy: 'created_at DESC');
  }

  // Moderation report operations
  Future<int> insertModerationReport(int reporterId, int reportedUserId, String reason) async {
    final db = await database;
    return await db.insert('moderation_reports', {
      'reporter_id': reporterId,
      'reported_user_id': reportedUserId,
      'reason': reason,
    });
  }

  Future<List<Map<String, dynamic>>> getModerationReports() async {
    final db = await database;
    return await db.query('moderation_reports', orderBy: 'created_at DESC');
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
