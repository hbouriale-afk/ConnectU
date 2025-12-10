
import 'package:flutter/material.dart';
import '../models/user_data.dart';
import '../services/database_helper.dart';
import 'event_details.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';
  final UserData userData = UserData();
  final DatabaseHelper databaseHelper = DatabaseHelper();
  final List<String> categories = ['All', 'Sports', 'Technology', 'Arts'];

  final List<Map<String, dynamic>> allEvents = [
    {
      'id': 1,
      'title': 'Campus Football Match',
      'description': 'Join us for an exciting football match on campus! All skill levels welcome.',
      'date': 'Today',
      'time': '4:00 PM',
      'location': 'Sports Field',
      'going': 24,
      'match': 95,
      'category': 'Sports',
      'mood': 'Excited',
    },
    {
      'id': 2,
      'title': 'Tech Innovation Workshop',
      'description': 'Learn about the latest innovations in technology and AI. Hands-on workshop with industry experts.',
      'date': 'Tomorrow',
      'time': '6:00 PM',
      'location': 'Building C, Room 201',
      'going': 18,
      'match': 88,
      'category': 'Technology',
      'mood': 'Focused',
    },
    {
      'id': 3,
      'title': 'Art Exhibition Opening',
      'description': 'Celebrate student artwork at our gallery opening. Free refreshments and live music.',
      'date': 'This Friday',
      'time': '7:00 PM',
      'location': 'Campus Gallery',
      'going': 32,
      'match': 92,
      'category': 'Arts',
      'mood': 'Happy',
    },
    {
      'id': 4,
      'title': 'Sports Yoga Session',
      'description': 'Relax and stretch with our yoga instructor. Perfect for beginners and experienced yogis.',
      'date': 'Wednesday',
      'time': '5:30 PM',
      'location': 'Gym Studio',
      'going': 15,
      'match': 90,
      'category': 'Sports',
      'mood': 'Relaxed',
    },
    {
      'id': 5,
      'title': 'AI & Machine Learning Talk',
      'description': 'Expert talk on artificial intelligence and machine learning applications in modern industry.',
      'date': 'Thursday',
      'time': '3:00 PM',
      'location': 'Main Auditorium',
      'going': 45,
      'match': 85,
      'category': 'Technology',
      'mood': 'Motivated',
    },
  ];

  List<Map<String, dynamic>> getFilteredEvents() {
    List<Map<String, dynamic>> filtered = allEvents;

    // Filter by category
    if (selectedCategory != 'All') {
      filtered = filtered.where((event) => event['category'] == selectedCategory).toList();
    }

    // Filter by mood - suggest events that match the user's current mood
    String userMood = userData.userMood;
    filtered.sort((a, b) {
      // Events matching the user's mood should appear first
      bool aMoodMatch = a['mood'] == userMood;
      bool bMoodMatch = b['mood'] == userMood;
      
      if (aMoodMatch && !bMoodMatch) return -1;
      if (!aMoodMatch && bMoodMatch) return 1;
      
      // Then sort by match percentage
      return (b['match'] as int).compareTo(a['match'] as int);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events For You'),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You have 2 new notifications')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://th.bing.com/th/id/R.230f1513b15667735422f2a17d77a132?rik=gmvL0%2fjd12PLSw&riu=http%3a%2f%2fuserscontent2.emaze.com%2fimages%2febcbc423-ad46-41a5-ac9c-26d150c182c3%2f635410398447100348_DSCN0211.JPG&ehk=yP4M3Tn0iNwHqPiHQoIish2rUbu3Sws9IZJsaACM5gk%3d&risl=&pid=ImgRaw&r=0',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = category;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Filtered by $category')),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Events For You',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening filters...')),
                      );
                    },
                  ),
                ],
              ),
            ),
            ...getFilteredEvents().map((event) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    event['title'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EventDetailsScreen(
                                          event: event,
                                          databaseHelper: databaseHelper,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Text('${event['date']}, ${event['time']}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(child: Text(event['location'])),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.people, size: 16),
                                const SizedBox(width: 4),
                                Text('${event['going']} going'),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.cyan.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${event['match']}% Match',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.cyan,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Registered for ${event['title']}!'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyan,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Register'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/messages');
              break;
            case 2:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}
