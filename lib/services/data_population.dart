import 'database.dart';

class DataPopulationService {
  static final DataPopulationService _instance = DataPopulationService._internal();

  factory DataPopulationService() {
    return _instance;
  }

  DataPopulationService._internal();

  Future<void> populateInitialData() async {
    final dbService = DatabaseService();

    try {
      // Check if data already exists
      final events = await dbService.getAllEvents();
      if (events.isNotEmpty) {
        print('Database already populated');
        return;
      }

      print('Starting database population...');

      // Insert sample interests
      final interests = [
        'Sports',
        'Music',
        'Travel',
        'Tech',
        'Art',
        'Gaming',
        'Reading',
        'Food',
        'Photography',
        'Fitness',
        'Movies',
        'Cooking',
      ];

      Map<String, int> interestIds = {};
      for (final interest in interests) {
        try {
          final id = await dbService.insertInterest(interest);
          interestIds[interest] = id;
          print('Added interest: $interest');
        } catch (e) {
          print('Interest might already exist: $interest');
        }
      }

      // Insert sample events
      final eventsData = [
        {
          'title': 'Campus Marathon',
          'description': 'Join us for a fun 5K run around campus',
          'location': 'Campus Sports Field',
          'created_by': 1,
        },
        {
          'title': 'Tech Talk: AI and Future',
          'description': 'Explore the future of artificial intelligence and machine learning',
          'location': 'Engineering Building Room 201',
          'created_by': 1,
        },
        {
          'title': 'Art Exhibition Opening',
          'description': 'Student artwork showcase featuring paintings, sculptures, and digital art',
          'location': 'Art Gallery, Student Center',
          'created_by': 1,
        },
        {
          'title': 'Gaming Tournament',
          'description': 'Competitive gaming tournament - League of Legends and Counter-Strike 2',
          'location': 'Computer Lab Building',
          'created_by': 1,
        },
        {
          'title': 'Jazz Night',
          'description': 'Live jazz performance by campus band and guest musicians',
          'location': 'Main Auditorium',
          'created_by': 1,
        },
        {
          'title': 'Food Festival',
          'description': 'International cuisine tasting event with food from around the world',
          'location': 'Campus Courtyard',
          'created_by': 1,
        },
        {
          'title': 'Photography Workshop',
          'description': 'Learn photography basics and advanced techniques',
          'location': 'Fine Arts Building',
          'created_by': 1,
        },
        {
          'title': 'Book Club Meeting',
          'description': 'Monthly discussion of "The Midnight Library"',
          'location': 'Library - Floor 3, Study Area',
          'created_by': 1,
        },
        {
          'title': 'Fitness Challenge Week',
          'description': 'Week-long fitness challenge with daily activities and prizes',
          'location': 'Gym and Outdoor Sports Fields',
          'created_by': 1,
        },
        {
          'title': 'Movie Marathon Night',
          'description': 'Watch classic and new movies with friends - Snacks provided',
          'location': 'Student Center Cinema',
          'created_by': 1,
        },
        {
          'title': 'Cooking Competition',
          'description': 'Show your culinary skills in friendly cooking competition',
          'location': 'University Kitchen',
          'created_by': 1,
        },
        {
          'title': 'Travel Stories Meetup',
          'description': 'Share travel experiences and plan future trips together',
          'location': 'Café Central',
          'created_by': 1,
        },
        {
          'title': 'Robotics Fair',
          'description': 'Showcase of student robotics projects and innovations',
          'location': 'Engineering Lab',
          'created_by': 1,
        },
        {
          'title': 'Open Mic Night',
          'description': 'Share your talent - comedy, music, poetry, and more',
          'location': 'Student Lounge',
          'created_by': 1,
        },
        {
          'title': 'Beach Volleyball Tournament',
          'description': 'Sand volleyball tournament with team spirit and prizes',
          'location': 'Beach Court',
          'created_by': 1,
        },
      ];

      for (final event in eventsData) {
        await dbService.insertEvent(event);
        print('Added event: ${event['title']}');
      }

      print('Database population completed successfully!');
    } catch (e) {
      print('Error populating database: $e');
    }
  }
}
