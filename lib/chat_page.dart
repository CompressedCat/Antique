import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final String otherUserId;

  const ChatPage({Key? key, required this.otherUserId}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _currentUserId;
  String _otherUserName = '';
  late String _username;

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser!.uid;
    _loadOtherUserName();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = _auth.currentUser;
      DocumentSnapshot userDoc = await _firestore.collection('Users').doc(user!.uid).get();
      setState(() {
        _username = userDoc['username'];
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadOtherUserName() async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('Users').doc(widget.otherUserId).get();
      if (userDoc.exists) {
        setState(() {
          _otherUserName = userDoc.get('username') ?? '';
        });
      } else {
        print('User document does not exist');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      try {
        await _firestore.collection('messages').add({
          'text': _messageController.text.trim(),
          'senderId': _currentUserId,
          'receiverId': widget.otherUserId,
          'chatParticipants': [_currentUserId, widget.otherUserId],
          'timestamp': FieldValue.serverTimestamp(),
        });
        _messageController.clear();
      } catch (e) {
        print('Error sending message: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message')),
        );
      }
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    String formattedTime = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$formattedDate $formattedTime';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFBFA58D),
        title: Text('Chat - $_otherUserName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Add your action here
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                _username.isNotEmpty ? _username : 'User',
                style: const TextStyle(
                  fontFamily: 'Cinzel',
                  color: Color(0xFF3E2723),
                ),
              ),
              accountEmail: Text(
                _auth.currentUser?.email ?? '',
                style: const TextStyle(
                  fontFamily: 'Cinzel',
                  color: Color(0xFF3E2723),
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  _username.isNotEmpty ? _username.substring(0, 1) : 'U',
                  style: const TextStyle(
                    fontSize: 40.0,
                    color: Color(0xFF3E2723),
                  ),
                ),
              ),
              onDetailsPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
              decoration: const BoxDecoration(
                color: Color(0xFFBFA58D), // Antique color
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home', style: TextStyle(fontFamily: 'Cinzel')),
              onTap: () {
                Navigator.pushNamed(context, '/homepage'); // Navigate to HomePage
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Map', style: TextStyle(fontFamily: 'Cinzel')),
              onTap: () {
                Navigator.pushNamed(context, '/map'); // Navigate to MapPage
              },
            ),
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text('List of Workshops', style: TextStyle(fontFamily: 'Cinzel')),
              onTap: () {
                Navigator.pushNamed(context, '/workshops'); // Navigate to WorkshopsPage
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Chat', style: TextStyle(fontFamily: 'Cinzel')),
              onTap: () {
                Navigator.pushNamed(context, '/chatlist'); // Navigate to ChatListPage
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout', style: TextStyle(fontFamily: 'Cinzel')),
              onTap: _logOut,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .where('chatParticipants', arrayContains: _currentUserId)
                  .orderBy('timestamp',)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print('Error: ${snapshot.error}');
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }

                final allMessages = snapshot.data!.docs.where((doc) {
                  return (doc['senderId'] == _currentUserId && doc['receiverId'] == widget.otherUserId) ||
                      (doc['senderId'] == widget.otherUserId && doc['receiverId'] == _currentUserId);
                }).toList();

                allMessages.sort((a, b) => (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));

                return ListView.builder(
                  reverse: true,
                  itemCount: allMessages.length,
                  itemBuilder: (context, index) {
                    final message = allMessages[index];
                    final messageText = message['text'];
                    final messageSender = message['senderId'];
                    final timestamp = message['timestamp'] as Timestamp;

                    return Align(
                      alignment: messageSender == _currentUserId ? Alignment.centerLeft : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: messageSender == _currentUserId ? Colors.blue[100] : Colors.green[100],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(messageText, style: const TextStyle(fontSize: 16.0)),
                            const SizedBox(height: 4.0),
                            Text(_formatTimestamp(timestamp), style: TextStyle(color: Colors.grey[600], fontSize: 12.0)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(color: Colors.transparent, width: 0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logOut() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print('Error logging out: $e');
    }
  }
}
