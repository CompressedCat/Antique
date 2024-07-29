import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_page.dart';

class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _currentUserId;
  late String _username = '';

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser!.uid;
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    try {
      User? user = _auth.currentUser;
      DocumentSnapshot userDoc =
      await _firestore.collection('Users').doc(user!.uid).get();
      setState(() {
        _username = userDoc['username'] ?? '';
      });
    } catch (e) {
      print('Error loading username: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFBFA58D), // Antique color
        title: const Text(
          'Chats',
          style: TextStyle(
            fontFamily: 'Cinzel', // Antique themed font
            color: Color(0xFF3E2723),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications button pressed
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logOut,
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
                Navigator.pop(context); // Close the drawer
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('messages')
            .where('senderId', isEqualTo: _currentUserId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No chats found.'));
          }

          final messages = snapshot.data!.docs;

          // To keep track of unique chat partners
          final chatPartners = <String>{};

          for (var message in messages) {
            chatPartners.add(message['receiverId']);
          }

          return ListView(
            children: chatPartners.map((partnerId) {
              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('Users').doc(partnerId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(
                      title: Text('Loading...'),
                    );
                  }
                  final userDoc = userSnapshot.data!;
                  final partnerName = userDoc['username'] ?? 'Unknown';

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: ListTile(
                      title: Text('Chat with: $partnerName'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(otherUserId: partnerId),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
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
