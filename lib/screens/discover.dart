
import 'package:flutter/material.dart';
import '../models/user_data.dart';
import '../services/database_helper.dart';
import '../models/user_session.dart';
import 'chat_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final UserData userData = UserData();
  final DatabaseHelper databaseHelper = DatabaseHelper();
  final UserSession userSession = UserSession();
  List<Map<String, dynamic>>? allUsers;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllUsers();
  }

  Future<void> _loadAllUsers() async {
    try {
      final users = await databaseHelper.getAllUsers();
      setState(() {
        allUsers = users.where((u) => u['id'] != userSession.userId).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  final List<Map<String, dynamic>> allStudents = [
    {
      'initials': 'AJ',
      'name': 'Alex Johnson',
      'major': 'Business Admin',
      'year': 'Junior',
      'interests': ['Sports', 'Music', 'Travel'],
      'personality': 'Extrovert',
    },
    {
      'initials': 'MP',
      'name': 'Maya Patel',
      'major': 'Computer Science',
      'year': 'Sophomore',
      'interests': ['Tech', 'Gaming', 'Reading'],
      'personality': 'Neutral',
    },
    {
      'initials': 'JW',
      'name': 'James Wilson',
      'major': 'Engineering',
      'year': 'Junior',
      'interests': ['Tech', 'Gaming', 'Art'],
      'personality': 'Introvert',
    },
    {
      'initials': 'SK',
      'name': 'Sofia Khan',
      'major': 'Fine Arts',
      'year': 'Sophomore',
      'interests': ['Art', 'Music', 'Food'],
      'personality': 'Extrovert',
    },
    {
      'initials': 'RV',
      'name': 'Ravi Verma',
      'major': 'Sports Science',
      'year': 'Freshman',
      'interests': ['Sports', 'Travel', 'Gaming'],
      'personality': 'Extrovert',
    },
  ];

  List<Map<String, dynamic>> getMatchedStudents() {
    if (allUsers == null) return [];
    
    // Create mutable copies and calculate match percentage for each student
    List<Map<String, dynamic>> mutableUsers = allUsers!.map<Map<String, dynamic>>((student) {
      final interests = student['interests'];
      List<String> interestList = <String>[];
      if (interests != null && interests.isNotEmpty) {
        final splitInterests = interests.toString().split(',');
        interestList = splitInterests.map<String>((e) => e.toString().trim()).toList();
      }
      
      // Create a mutable copy of the student map
      Map<String, dynamic> mutableStudent = Map<String, dynamic>.from(student);
      mutableStudent['match'] = userData.calculateMatchPercentage(interestList);
      return mutableStudent;
    }).toList();
    
    // Sort by match percentage (highest first)
    mutableUsers.sort((a, b) => (b['match'] as int).compareTo(a['match'] as int));
    return mutableUsers;
  }

  void _showNewChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Chat'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : allUsers == null || allUsers!.isEmpty
                  ? const Center(child: Text('No users found'))
                  : ListView.builder(
                      itemCount: allUsers!.length,
                      itemBuilder: (context, index) {
                        final user = allUsers![index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.cyan,
                            child: Text(
                              user['name'] != null && user['name'].isNotEmpty
                                  ? user['name'][0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(user['name'] ?? 'Unknown'),
                          subtitle: Text(
                            '${user['major'] ?? 'Major not set'} • ${user['year'] ?? 'Year not set'}',
                          ),
                          onTap: () async {
                            Navigator.pop(context);
                            if (userSession.userId != null) {
                              final chatId = await databaseHelper.createOrGetChat(
                                userSession.userId!,
                                user['id'],
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    chatId: chatId,
                                    otherUser: user,
                                    databaseHelper: databaseHelper,
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'New Chat',
            onPressed: _showNewChatDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.withOpacity(0.1),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Smart Matching',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'These students have interests and preferences similar to yours. Start a conversation to connect',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            ...getMatchedStudents().map((student) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.blue,
                              child: Text(
                                student['name'] != null && student['name'].isNotEmpty
                                    ? student['name'][0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        student['name'] ?? 'Unknown',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '${student['match']}% Match',
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${student['major'] ?? 'Major not set'} • ${student['year'] ?? 'Year not set'}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    student['mood'] ?? 'Neutral',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: () {
                            final interests = student['interests'];
                            if (interests == null || interests.isEmpty) {
                              return [const Chip(label: Text('No interests'))];
                            }
                            final interestList = interests.split(',').map((e) => e.trim()).toList();
                            return interestList.map((interest) {
                              return Chip(
                                label: Text(interest),
                              );
                            }).toList();
                          }(),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (userSession.userId != null) {
                                final chatId = await databaseHelper.createOrGetChat(
                                  userSession.userId!,
                                  student['id'],
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      chatId: chatId,
                                      otherUser: student,
                                      databaseHelper: databaseHelper,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text('Send Message'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
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
              Navigator.pushNamed(context, '/discover');
              break;
            case 2:
              Navigator.pushNamed(context, '/messages');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewChatDialog,
        icon: const Icon(Icons.message),
        label: const Text('New Chat'),
        backgroundColor: Colors.cyan,
      ),
    );
  }
}
