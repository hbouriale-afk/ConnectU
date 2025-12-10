
import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/user_session.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final DatabaseHelper databaseHelper = DatabaseHelper();
  final UserSession userSession = UserSession();
  List<Map<String, dynamic>> conversations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      if (userSession.userId == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final chats = await databaseHelper.getUserChats(userSession.userId!);
      
      List<Map<String, dynamic>> loadedConversations = [];
      for (var chat in chats) {
        final otherUserId = chat['user1_id'] == userSession.userId 
            ? chat['user2_id'] 
            : chat['user1_id'];
        
        final otherUser = await databaseHelper.getUserById(otherUserId);
        if (otherUser != null) {
          final lastMessage = await databaseHelper.getLastMessage(chat['id']);
          
          loadedConversations.add({
            'chatId': chat['id'],
            'otherUser': otherUser,
            'name': otherUser['name'] ?? 'Unknown',
            'lastMessage': lastMessage?['message_text'] ?? 'No messages yet',
            'time': _formatTime(lastMessage?['sent_at']),
          });
        }
      }
      
      setState(() {
        conversations = loadedConversations;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading conversations: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(date);
      
      if (diff.inDays == 0) {
        return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else if (diff.inDays == 1) {
        return 'Yesterday';
      } else {
        return '${diff.inDays} days ago';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : conversations.isEmpty
              ? const Center(
                  child: Text(
                    'No conversations yet\nStart chatting with someone!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search conversations...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: conversations.length,
                        itemBuilder: (context, index) {
                          final conv = conversations[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                conv['name'] != null && conv['name'].isNotEmpty
                                    ? conv['name'][0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              conv['name'],
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              conv['lastMessage'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              conv['time'],
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    chatId: conv['chatId'],
                                    otherUser: conv['otherUser'],
                                    databaseHelper: databaseHelper,
                                  ),
                                ),
                              ).then((_) => _loadConversations());
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
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
