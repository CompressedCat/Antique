import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'createcontent.dart';
import 'mappage.dart';
import 'web_map.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String _username;
  late String _userType; // Added to store user type

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = _auth.currentUser;
      DocumentSnapshot userDoc = await _firestore.collection('Users').doc(user!.uid).get();
      setState(() {
        _username = userDoc['username'];
        _userType = userDoc['user_type'];
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<List<DocumentSnapshot<Object?>>> _getContents() async {
    try {
      QuerySnapshot<Object?> querySnapshot = await _firestore
          .collection('content')
          .orderBy('created_at', descending: true) // Sorting by latest first
          .get();
      return querySnapshot.docs;
    } catch (e) {
      print('Error fetching contents: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFBFA58D), // Antique color
        title: const Text(
          'Home',
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
      body: FutureBuilder<List<DocumentSnapshot<Object?>>>(
        future: _getContents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No content available'),
            );
          } else {
            List<DocumentSnapshot<Object?>> contents = snapshot.data!;
            return ListView.builder(
              itemCount: contents.length,
              itemBuilder: (context, index) {
                var contentData =
                contents[index].data() as Map<String, dynamic>;
                var currentUser = _auth.currentUser;
                bool isOwner =
                    currentUser?.uid == contentData['user_id'] || _userType == 'admin'; // Check if admin or content owner

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF8D6E63), // Border color
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF5F5F5), // Background color for content
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/content_detail',
                        arguments: contents[index],
                      );
                    },
                    title: Text(
                      contentData['title'] ?? '',
                      style: const TextStyle(
                        fontFamily: 'Cinzel',
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contentData['username'] ?? 'Unknown User',
                          style: const TextStyle(
                            fontFamily: 'Cinzel',
                            color: Color(0xFF6D4C41),
                          ),
                        ),
                        Text(
                          contentData['created_at'] != null
                              ? (contentData['created_at'] as Timestamp)
                              .toDate()
                              .toString()
                              : '',
                          style: const TextStyle(
                            fontFamily: 'Cinzel',
                            color: Color(0xFF6D4C41),
                          ),
                        ),
                      ],
                    ),
                    trailing: isOwner
                        ? PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateContentPage(
                                existingContent: contents[index],
                              ),
                            ),
                          );
                        } else if (value == 'delete') {
                          _deleteContent(contents[index].id);
                        }
                      },
                      itemBuilder: (context) => [
                        if (_userType == 'admin' || isOwner) // Allow delete for admin or owner
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        if (isOwner) // Allow edit for owner
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                      ],
                    )
                        : null,
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8D6E63), // Antique button color
        onPressed: () {
          Navigator.pushNamed(context, '/create_content');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteContent(String docId) async {
    try {
      await _firestore.collection('content').doc(docId).delete();
      setState(() {}); // Refresh UI after deletion
    } catch (e) {
      print('Error deleting content: $e');
    }
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
