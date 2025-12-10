import 'package:flutter/material.dart';
import 'dart:io';
import '../models/user_data.dart';
import '../models/user_session.dart';
import '../services/database_helper.dart';
import 'event_details.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String selectedMood;
  late List<String> userInterests;
  final UserData userData = UserData();
  final UserSession userSession = UserSession();
  final DatabaseHelper databaseHelper = DatabaseHelper();
  final List<String> allMoods = ['Low', 'Sad', 'Okay', 'Happy', 'Excited'];
  final List<String> allInterests = ['Sports', 'Music', 'Travel', 'Tech', 'Art', 'Gaming', 'Reading', 'Food'];
  List<Map<String, dynamic>> recommendedEvents = [];
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    selectedMood = userSession.userMood ?? 'Happy';
    userInterests = userSession.userInterests != null 
        ? List.from(userSession.userInterests!) 
        : [];
    _loadRecommendedEvents();
    _loadProfileImage();
    _loadUserDataFromDatabase();
  }

  Future<void> _loadUserDataFromDatabase() async {
    if (userSession.userId != null) {
      final user = await databaseHelper.getUserById(userSession.userId!);
      if (user != null) {
        setState(() {
          if (user['interests'] != null && user['interests'].toString().isNotEmpty) {
            userInterests = user['interests'].toString().split(',');
          }
          if (user['mood'] != null) {
            selectedMood = user['mood'];
          }
        });
      }
    }
  }

  Future<void> _loadProfileImage() async {
    if (userSession.userId != null) {
      final user = await databaseHelper.getUserById(userSession.userId!);
      if (user != null && user['profile_image'] != null) {
        setState(() {
          _profileImagePath = user['profile_image'];
        });
      }
    }
  }

  Future<void> _loadRecommendedEvents() async {
    try {
      final events = await databaseHelper.getEventsByMood(selectedMood);
      print('Loaded ${events.length} events for mood: $selectedMood');
      if (events.isEmpty) {
        print('DEBUG: No events found for mood $selectedMood. Fetching all events to debug...');
        final allEvents = await databaseHelper.getAllEvents();
        print('Total events in DB: ${allEvents.length}');
        for (var event in allEvents) {
          print('Event: ${event['title']}, Mood: ${event['mood']}');
        }
      }
      setState(() {
        recommendedEvents = events;
      });
    } catch (e) {
      print('Error loading events: $e');
      setState(() {
        recommendedEvents = [];
      });
    }
  }

  void _uploadPhoto() async {
    final pathController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter image path'),
        content: TextField(
          controller: pathController,
          decoration: const InputDecoration(
            hintText: 'e.g., C:\\Users\\Pictures\\photo.jpg',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final path = pathController.text.trim();
              if (path.isNotEmpty && File(path).existsSync()) {
                if (userSession.userId != null) {
                  databaseHelper.updateProfileImage(userSession.userId!, path);
                  setState(() {
                    _profileImagePath = path;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile picture updated!')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid file path')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _toggleInterest(String interest) async {
    setState(() {
      if (userInterests.contains(interest)) {
        userInterests.remove(interest);
      } else if (userInterests.length < 5) {
        userInterests.add(interest);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can select up to 5 interests')),
        );
        return;
      }
      // Update global user data
      userData.setUserInterests(userInterests);
    });

    // Save to database
    if (userSession.userId != null) {
      final interestsString = userInterests.join(',');
      await databaseHelper.updateUserInterests(userSession.userId!, interestsString);
      userSession.setInterests(userInterests);
    }
  }

  String _getMoodEmoji(String mood) {
    final moodEmojis = {
      'Low': '😞',
      'Sad': '😢',
      'Okay': '😐',
      'Happy': '😊',
      'Excited': '🤩',
    };
    return moodEmojis[mood] ?? '😊';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.cyan,
                        backgroundImage: _profileImagePath != null && File(_profileImagePath!).existsSync()
                            ? FileImage(File(_profileImagePath!))
                            : null,
                        child: _profileImagePath == null || !File(_profileImagePath!).existsSync()
                            ? Text(
                                userSession.userName != null && userSession.userName!.isNotEmpty
                                    ? userSession.userName![0].toUpperCase()
                                    : 'M',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.cyan,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                            onPressed: _uploadPhoto,
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userSession.userName ?? 'User',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${userSession.userMajor ?? 'Major not set'} • ${userSession.userYear ?? 'Year not set'}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening edit profile...')),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildStatsSection(),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildInterestsSection(),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildPrivacySection(),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How are you feeling?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: allMoods.map((mood) {
                      final isSelected = selectedMood == mood;
                      return GestureDetector(
                        onTap: () async {
                          setState(() {
                            selectedMood = mood;
                          });
                          // Update global user data
                          userData.setUserMood(mood);
                          userSession.setMood(mood);
                          
                          // Save to database if user is logged in
                          if (userSession.userId != null) {
                            await databaseHelper.updateUserMood(
                              userSession.userId!,
                              mood,
                            );
                          }

                          // Load events for this mood
                          await _loadRecommendedEvents();
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('You\'re feeling $mood! Loading events for you.'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(color: Colors.cyan, width: 3)
                                    : null,
                              ),
                              child: Text(
                                _getMoodEmoji(mood),
                                style: const TextStyle(fontSize: 40),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              mood,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.cyan : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildRecommendedEventsSection(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stats',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatCard('Events', '12'),
            _buildStatCard('Connections', '24'),
            _buildStatCard('Chats', '8'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.cyan,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Interests',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allInterests.map((interest) {
            final isSelected = userInterests.contains(interest);
            return FilterChip(
              label: Text(interest),
              selected: isSelected,
              onSelected: (selected) {
                _toggleInterest(interest);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Privacy',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Profile visibility: Public'),
              Icon(Icons.visibility),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Events For You',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (recommendedEvents.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('No events available yet'),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recommendedEvents.take(3).length,
            itemBuilder: (context, index) {
              final event = recommendedEvents[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['title'] ?? 'Untitled Event',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event['location'] ?? 'Location TBA',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event['description'] ?? '',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Mood: ${event['mood'] ?? 'Any'}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.cyan,
                            ),
                          ),
                        ),
                        ElevatedButton(
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
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          ),
                          child: const Text('Details', style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
