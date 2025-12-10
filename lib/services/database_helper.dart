import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'connectu.db');
    return await openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add mood column to events table if it doesn't exist
      try {
        await db.execute('ALTER TABLE events ADD COLUMN mood TEXT');
        print('Added mood column to events table');
      } catch (e) {
        print('Mood column may already exist: $e');
      }
    }
    
    if (oldVersion < 3) {
      try {
        // Delete old events without mood and recreate them with proper mood values
        await db.delete('events');
        print('Cleared old events to repopulate with mood data');
        
        // Re-insert events with mood
        final eventsData = [
          // Excited Mood Events
          {'title': 'Campus Marathon', 'description': 'Join us for a fun 5K run around campus', 'location': 'Campus Sports Field', 'mood': 'Excited'},
          {'title': 'Gaming Tournament', 'description': 'Competitive gaming tournament - League of Legends and Counter-Strike 2', 'location': 'Computer Lab Building', 'mood': 'Excited'},
          {'title': 'Fitness Challenge Week', 'description': 'Week-long fitness challenge with daily activities and prizes', 'location': 'Gym and Outdoor Sports Fields', 'mood': 'Excited'},
          {'title': 'Cooking Competition', 'description': 'Show your culinary skills in friendly cooking competition', 'location': 'University Kitchen', 'mood': 'Excited'},
          {'title': 'Robotics Fair', 'description': 'Showcase of student robotics projects and innovations', 'location': 'Engineering Lab', 'mood': 'Excited'},
          {'title': 'Beach Volleyball Tournament', 'description': 'Sand volleyball tournament with team spirit and prizes', 'location': 'Beach Court', 'mood': 'Excited'},
          
          // Happy Mood Events
          {'title': 'Tech Talk: AI and Future', 'description': 'Explore the future of artificial intelligence and machine learning', 'location': 'Engineering Building Room 201', 'mood': 'Happy'},
          {'title': 'Art Exhibition Opening', 'description': 'Student artwork showcase featuring paintings, sculptures, and digital art', 'location': 'Art Gallery, Student Center', 'mood': 'Happy'},
          {'title': 'Food Festival', 'description': 'International cuisine tasting event with food from around the world', 'location': 'Campus Courtyard', 'mood': 'Happy'},
          {'title': 'Movie Marathon Night', 'description': 'Watch classic and new movies with friends - Snacks provided', 'location': 'Student Center Cinema', 'mood': 'Happy'},
          {'title': 'Travel Stories Meetup', 'description': 'Share travel experiences and plan future trips together', 'location': 'Café Central', 'mood': 'Happy'},
          {'title': 'Open Mic Night', 'description': 'Share your talent - comedy, music, poetry, and more', 'location': 'Student Lounge', 'mood': 'Happy'},
          {'title': 'Comedy Night', 'description': 'Student comedy show featuring hilarious performances', 'location': 'Student Center Auditorium', 'mood': 'Happy'},
          
          // Okay Mood Events
          {'title': 'Jazz Night', 'description': 'Live jazz performance by campus band and guest musicians', 'location': 'Main Auditorium', 'mood': 'Okay'},
          {'title': 'Photography Workshop', 'description': 'Learn photography basics and advanced techniques', 'location': 'Fine Arts Building', 'mood': 'Okay'},
          {'title': 'Book Club Meeting', 'description': 'Monthly discussion of "The Midnight Library"', 'location': 'Library - Floor 3, Study Area', 'mood': 'Okay'},
          {'title': 'Meditation & Yoga Session', 'description': 'Relaxing meditation and yoga class for students', 'location': 'Wellness Center', 'mood': 'Okay'},
          {'title': 'Study Group Formation', 'description': 'Meet fellow students and form study groups for exams', 'location': 'Library Meeting Room', 'mood': 'Okay'},
          {'title': 'Art Crafting Workshop', 'description': 'Create DIY crafts and art projects', 'location': 'Art Studio', 'mood': 'Okay'},
          
          // Sad Mood Events
          {'title': 'Supportive Friends Circle', 'description': 'A safe space to share and listen to each other', 'location': 'Counseling Center', 'mood': 'Sad'},
          {'title': 'Mindfulness Retreat', 'description': 'Day retreat focused on self-care and healing', 'location': 'Campus Garden', 'mood': 'Sad'},
          {'title': 'Documentary Film Night', 'description': 'Watch meaningful documentaries and discuss', 'location': 'Student Center Cinema', 'mood': 'Sad'},
          {'title': 'Quiet Creative Writing Session', 'description': 'Express yourself through creative writing', 'location': 'Library Quiet Zone', 'mood': 'Sad'},
          {'title': 'Music Therapy Workshop', 'description': 'Healing through music and sound therapy', 'location': 'Music Room', 'mood': 'Sad'},
          
          // Low Mood Events
          {'title': 'Mental Health Awareness Talk', 'description': 'Learn about mental health and wellness resources', 'location': 'Health Center', 'mood': 'Low'},
          {'title': 'Gentle Nature Walk', 'description': 'Peaceful walk around campus nature trails', 'location': 'Campus Trails', 'mood': 'Low'},
          {'title': 'Peer Support Group', 'description': 'Connect with others facing similar challenges', 'location': 'Student Services', 'mood': 'Low'},
          {'title': 'Art Therapy Session', 'description': 'Healing through creative expression and art', 'location': 'Art Studio', 'mood': 'Low'},
          {'title': 'Quiet Coffee Social', 'description': 'Low-pressure hangout over coffee', 'location': 'Campus Café', 'mood': 'Low'},
        ];

        for (final event in eventsData) {
          await db.insert('events', event);
        }
        print('Repopulated ${eventsData.length} events with mood data');
      } catch (e) {
        print('Migration error: $e');
      }
    }
    
    if (oldVersion < 4) {
      try {
        // Add sample users for events
        final sampleUsers = [
          {'name': 'Alex Johnson', 'email': 'alex.johnson@aui.ma', 'password': 'test123', 'major': 'Business Admin', 'year': 'Junior', 'interests': 'Sports,Music,Travel'},
          {'name': 'Maya Patel', 'email': 'maya.patel@aui.ma', 'password': 'test123', 'major': 'Computer Science', 'year': 'Sophomore', 'interests': 'Tech,Gaming,Reading'},
          {'name': 'James Wilson', 'email': 'james.wilson@aui.ma', 'password': 'test123', 'major': 'Engineering', 'year': 'Junior', 'interests': 'Tech,Gaming,Art'},
          {'name': 'Sofia Khan', 'email': 'sofia.khan@aui.ma', 'password': 'test123', 'major': 'Fine Arts', 'year': 'Sophomore', 'interests': 'Art,Music,Food'},
          {'name': 'Ravi Verma', 'email': 'ravi.verma@aui.ma', 'password': 'test123', 'major': 'Sports Science', 'year': 'Freshman', 'interests': 'Sports,Travel,Gaming'},
        ];
        
        for (final user in sampleUsers) {
          try {
            await db.insert('users', user);
          } catch (e) {
            print('User might already exist: ${user['email']}');
          }
        }
        print('Added ${sampleUsers.length} sample users');
        
        // Register users for events
        final registrations = [
          // Campus Marathon (event_id: 1) - Sports event
          {'user_id': 2, 'event_id': 1}, // Alex
          {'user_id': 6, 'event_id': 1}, // Ravi
          {'user_id': 3, 'event_id': 1}, // Maya
          
          // Gaming Tournament (event_id: 2)
          {'user_id': 3, 'event_id': 2}, // Maya
          {'user_id': 4, 'event_id': 2}, // James
          {'user_id': 6, 'event_id': 2}, // Ravi
          
          // Tech Talk: AI and Future (event_id: 7)
          {'user_id': 3, 'event_id': 7}, // Maya
          {'user_id': 4, 'event_id': 7}, // James
          {'user_id': 2, 'event_id': 7}, // Alex
          
          // Art Exhibition Opening (event_id: 8)
          {'user_id': 5, 'event_id': 8}, // Sofia
          {'user_id': 4, 'event_id': 8}, // James
          {'user_id': 2, 'event_id': 8}, // Alex
          
          // Food Festival (event_id: 9)
          {'user_id': 5, 'event_id': 9}, // Sofia
          {'user_id': 3, 'event_id': 9}, // Maya
          {'user_id': 6, 'event_id': 9}, // Ravi
          {'user_id': 2, 'event_id': 9}, // Alex
        ];
        
        for (final registration in registrations) {
          try {
            await db.insert('user_events', registration);
          } catch (e) {
            print('Registration might already exist');
          }
        }
        print('Registered users for ${registrations.length} events');
      } catch (e) {
        print('Error adding sample data: $e');
      }
    }
    
    if (oldVersion < 5) {
      try {
        // Create chats and messages tables if they don't exist
        await db.execute('''
          CREATE TABLE IF NOT EXISTS chats(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user1_id INTEGER NOT NULL,
            user2_id INTEGER NOT NULL,
            event_id INTEGER,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(user1_id, user2_id),
            FOREIGN KEY(user1_id) REFERENCES users(id),
            FOREIGN KEY(user2_id) REFERENCES users(id),
            FOREIGN KEY(event_id) REFERENCES events(id)
          )
        ''');
        print('Created chats table');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS messages(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            chat_id INTEGER NOT NULL,
            sender_id INTEGER NOT NULL,
            message_text TEXT NOT NULL,
            sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(chat_id) REFERENCES chats(id),
            FOREIGN KEY(sender_id) REFERENCES users(id)
          )
        ''');
        print('Created messages table');
      } catch (e) {
        print('Error creating chat tables: $e');
      }
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        major TEXT,
        year TEXT,
        interests TEXT,
        mood TEXT DEFAULT 'Happy',
        profile_image TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        location TEXT NOT NULL,
        mood TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE user_events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        event_id INTEGER NOT NULL,
        registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES users(id),
        FOREIGN KEY(event_id) REFERENCES events(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE chats(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user1_id INTEGER NOT NULL,
        user2_id INTEGER NOT NULL,
        event_id INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user1_id, user2_id),
        FOREIGN KEY(user1_id) REFERENCES users(id),
        FOREIGN KEY(user2_id) REFERENCES users(id),
        FOREIGN KEY(event_id) REFERENCES events(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE messages(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chat_id INTEGER NOT NULL,
        sender_id INTEGER NOT NULL,
        message_text TEXT NOT NULL,
        sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(chat_id) REFERENCES chats(id),
        FOREIGN KEY(sender_id) REFERENCES users(id)
      )
    ''');

    // Insert initial events with moods
    final eventsData = [
      // Excited Mood Events
      {'title': 'Campus Marathon', 'description': 'Join us for a fun 5K run around campus', 'location': 'Campus Sports Field', 'mood': 'Excited'},
      {'title': 'Gaming Tournament', 'description': 'Competitive gaming tournament - League of Legends and Counter-Strike 2', 'location': 'Computer Lab Building', 'mood': 'Excited'},
      {'title': 'Fitness Challenge Week', 'description': 'Week-long fitness challenge with daily activities and prizes', 'location': 'Gym and Outdoor Sports Fields', 'mood': 'Excited'},
      {'title': 'Cooking Competition', 'description': 'Show your culinary skills in friendly cooking competition', 'location': 'University Kitchen', 'mood': 'Excited'},
      {'title': 'Robotics Fair', 'description': 'Showcase of student robotics projects and innovations', 'location': 'Engineering Lab', 'mood': 'Excited'},
      {'title': 'Beach Volleyball Tournament', 'description': 'Sand volleyball tournament with team spirit and prizes', 'location': 'Beach Court', 'mood': 'Excited'},
      
      // Happy Mood Events
      {'title': 'Tech Talk: AI and Future', 'description': 'Explore the future of artificial intelligence and machine learning', 'location': 'Engineering Building Room 201', 'mood': 'Happy'},
      {'title': 'Art Exhibition Opening', 'description': 'Student artwork showcase featuring paintings, sculptures, and digital art', 'location': 'Art Gallery, Student Center', 'mood': 'Happy'},
      {'title': 'Food Festival', 'description': 'International cuisine tasting event with food from around the world', 'location': 'Campus Courtyard', 'mood': 'Happy'},
      {'title': 'Movie Marathon Night', 'description': 'Watch classic and new movies with friends - Snacks provided', 'location': 'Student Center Cinema', 'mood': 'Happy'},
      {'title': 'Travel Stories Meetup', 'description': 'Share travel experiences and plan future trips together', 'location': 'Café Central', 'mood': 'Happy'},
      {'title': 'Open Mic Night', 'description': 'Share your talent - comedy, music, poetry, and more', 'location': 'Student Lounge', 'mood': 'Happy'},
      {'title': 'Comedy Night', 'description': 'Student comedy show featuring hilarious performances', 'location': 'Student Center Auditorium', 'mood': 'Happy'},
      
      // Okay Mood Events
      {'title': 'Jazz Night', 'description': 'Live jazz performance by campus band and guest musicians', 'location': 'Main Auditorium', 'mood': 'Okay'},
      {'title': 'Photography Workshop', 'description': 'Learn photography basics and advanced techniques', 'location': 'Fine Arts Building', 'mood': 'Okay'},
      {'title': 'Book Club Meeting', 'description': 'Monthly discussion of "The Midnight Library"', 'location': 'Library - Floor 3, Study Area', 'mood': 'Okay'},
      {'title': 'Meditation & Yoga Session', 'description': 'Relaxing meditation and yoga class for students', 'location': 'Wellness Center', 'mood': 'Okay'},
      {'title': 'Study Group Formation', 'description': 'Meet fellow students and form study groups for exams', 'location': 'Library Meeting Room', 'mood': 'Okay'},
      {'title': 'Art Crafting Workshop', 'description': 'Create DIY crafts and art projects', 'location': 'Art Studio', 'mood': 'Okay'},
      
      // Sad Mood Events
      {'title': 'Supportive Friends Circle', 'description': 'A safe space to share and listen to each other', 'location': 'Counseling Center', 'mood': 'Sad'},
      {'title': 'Mindfulness Retreat', 'description': 'Day retreat focused on self-care and healing', 'location': 'Campus Garden', 'mood': 'Sad'},
      {'title': 'Documentary Film Night', 'description': 'Watch meaningful documentaries and discuss', 'location': 'Student Center Cinema', 'mood': 'Sad'},
      {'title': 'Quiet Creative Writing Session', 'description': 'Express yourself through creative writing', 'location': 'Library Quiet Zone', 'mood': 'Sad'},
      {'title': 'Music Therapy Workshop', 'description': 'Healing through music and sound therapy', 'location': 'Music Room', 'mood': 'Sad'},
      
      // Low Mood Events
      {'title': 'Mental Health Awareness Talk', 'description': 'Learn about mental health and wellness resources', 'location': 'Health Center', 'mood': 'Low'},
      {'title': 'Gentle Nature Walk', 'description': 'Peaceful walk around campus nature trails', 'location': 'Campus Trails', 'mood': 'Low'},
      {'title': 'Peer Support Group', 'description': 'Connect with others facing similar challenges', 'location': 'Student Services', 'mood': 'Low'},
      {'title': 'Art Therapy Session', 'description': 'Healing through creative expression and art', 'location': 'Art Studio', 'mood': 'Low'},
      {'title': 'Quiet Coffee Social', 'description': 'Low-pressure hangout over coffee', 'location': 'Campus Café', 'mood': 'Low'},
    ];

    for (final event in eventsData) {
      await db.insert('events', event);
    }
  }

  // User operations
  Future<int> insertUser({
    required String name,
    required String email,
    required String password,
    String? major,
    String? year,
    String? interests,
  }) async {
    final db = await database;
    final lowerEmail = email.toLowerCase();
    return await db.insert(
      'users',
      {
        'name': name,
        'email': lowerEmail,
        'password': password,
        'major': major,
        'year': year,
        'interests': interests,
      },
    );
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final lowerEmail = email.toLowerCase();
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [lowerEmail],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateUserMood(int userId, String mood) async {
    final db = await database;
    return await db.update(
      'users',
      {'mood': mood},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> updateUserInterests(int userId, String interests) async {
    final db = await database;
    return await db.update(
      'users',
      {'interests': interests},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> updateUserProfile(
    int userId, {
    required String major,
    required String year,
    required String interests,
  }) async {
    final db = await database;
    return await db.update(
      'users',
      {
        'major': major,
        'year': year,
        'interests': interests,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Event operations
  Future<int> insertEvent({
    required String title,
    required String date,
    required String time,
    required String location,
    required String category,
    String? mood,
  }) async {
    final db = await database;
    return await db.insert(
      'events',
      {
        'title': title,
        'date': date,
        'time': time,
        'location': location,
        'category': category,
        'mood': mood,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getAllEvents() async {
    final db = await database;
    return await db.query('events');
  }

  Future<List<Map<String, dynamic>>> getEventsByMood(String mood) async {
    final db = await database;
    return await db.query('events', where: 'mood = ?', whereArgs: [mood]);
  }

  Future<List<Map<String, dynamic>>> getEventParticipants(int eventId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT u.id, u.name, u.email, u.major, u.year, u.interests, u.mood 
      FROM users u
      JOIN user_events ue ON u.id = ue.user_id
      WHERE ue.event_id = ?
    ''', [eventId]);
  }

  Future<int> createOrGetChat(int user1Id, int user2Id, {int? eventId}) async {
    final db = await database;
    final minId = user1Id < user2Id ? user1Id : user2Id;
    final maxId = user1Id < user2Id ? user2Id : user1Id;

    final existing = await db.query(
      'chats',
      where: 'user1_id = ? AND user2_id = ?',
      whereArgs: [minId, maxId],
    );

    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }

    return await db.insert('chats', {
      'user1_id': minId,
      'user2_id': maxId,
      'event_id': eventId,
    });
  }

  Future<int> sendMessage(int chatId, int senderId, String messageText) async {
    final db = await database;
    return await db.insert('messages', {
      'chat_id': chatId,
      'sender_id': senderId,
      'message_text': messageText,
    });
  }

  Future<List<Map<String, dynamic>>> getMessages(int chatId) async {
    final db = await database;
    return await db.query(
      'messages',
      where: 'chat_id = ?',
      whereArgs: [chatId],
      orderBy: 'sent_at ASC',
    );
  }

  Future<Map<String, dynamic>?> getOtherUser(int chatId, int currentUserId) async {
    final db = await database;
    final chat = await db.query('chats', where: 'id = ?', whereArgs: [chatId]);
    if (chat.isEmpty) return null;

    final otherUserId = chat.first['user1_id'] == currentUserId
        ? chat.first['user2_id']
        : chat.first['user1_id'];

    return await getUserById(otherUserId as int);
  }

  Future<List<Map<String, dynamic>>> getUserChats(int userId) async {
    final db = await database;
    return await db.query(
      'chats',
      where: 'user1_id = ? OR user2_id = ?',
      whereArgs: [userId, userId],
      orderBy: 'created_at DESC',
    );
  }

  Future<Map<String, dynamic>?> getLastMessage(int chatId) async {
    final db = await database;
    final messages = await db.query(
      'messages',
      where: 'chat_id = ?',
      whereArgs: [chatId],
      orderBy: 'sent_at DESC',
      limit: 1,
    );
    return messages.isEmpty ? null : messages.first;
  }

  Future<int> updateProfileImage(int userId, String imagePath) async {
    final db = await database;
    return await db.update(
      'users',
      {'profile_image': imagePath},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // User events operations
  Future<int> registerUserForEvent(int userId, int eventId) async {
    final db = await database;
    return await db.insert(
      'user_events',
      {
        'user_id': userId,
        'event_id': eventId,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getUserRegisteredEvents(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT e.* FROM events e
      INNER JOIN user_events ue ON e.id = ue.event_id
      WHERE ue.user_id = ?
    ''', [userId]);
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users');
  }
}
