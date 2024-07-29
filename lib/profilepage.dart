import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'mappage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  Map<String, dynamic>? _userInfo;
  List<DocumentSnapshot<Object?>> _userContents = [];

  late String _username;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _fetchUserInfo();
      _fetchUserContents();
    }
  }

  Future<void> _fetchUserInfo() async {
    try {
      DocumentSnapshot<Object?> userDoc = await _firestore
          .collection('Users')
          .doc(_currentUser!.uid)
          .get();
      setState(() {
        _userInfo = userDoc.data() as Map<String, dynamic>?;
        _username = userDoc['username'] ?? 'Anonymous';
      });
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }

  Future<void> _fetchUserContents() async {
    try {
      QuerySnapshot<Object?> querySnapshot = await _firestore
          .collection('content')
          .where('user_id', isEqualTo: _currentUser!.uid)
          .orderBy('created_at', descending: false) // Sorting by FIFO
          .get();
      setState(() {
        _userContents = querySnapshot.docs;
      });
    } catch (e) {
      print('Error fetching user contents: $e');
    }
  }

  Future<void> _deleteContent(String docId) async {
    try {
      await _firestore.collection('content').doc(docId).delete();
      _fetchUserContents(); // Refresh the user content list after deletion
    } catch (e) {
      print('Error deleting content: $e');
    }
  }

  Future<void> _logOut() async {
    try {
      await _auth.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false); // Navigate to login and remove all routes
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFBFA58D), // Antique color
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
        centerTitle: true,
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
      body: _currentUser == null
          ? const Center(child: Text('No user logged in'))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _userInfo != null
                  ? _buildUserInfo()
                  : const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 20),
              const Text(
                'Your Content',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildUserContents(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${_userInfo!['username']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Email: ${_userInfo!['email']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Phone: ${_userInfo!['phone_number']}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserContents() {
    return _userContents.isNotEmpty
        ? Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!), // Adjust border color and width as needed
        borderRadius: BorderRadius.circular(10.0), // Adjust border radius as needed
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _userContents.length,
        itemBuilder: (context, index) {
          var contentData =
          _userContents[index].data() as Map<String, dynamic>;
          var currentUser = _auth.currentUser;
          bool isOwner = currentUser?.uid == contentData['user_id'];

          return ListTile(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/content_detail',
                arguments: _userContents[index],
              );
            },
            title: Text(contentData['title'] ?? ''),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contentData['username'] ?? 'Unknown User'),
                Text(
                  contentData['created_at'] != null
                      ? (contentData['created_at'] as Timestamp)
                      .toDate()
                      .toString()
                      : '',
                ),
              ],
            ),
            trailing: isOwner
                ? PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.pushNamed(
                    context,
                    '/edit_content',
                    arguments: _userContents[index],
                  );
                } else if (value == 'delete') {
                  _deleteContent(_userContents[index].id);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            )
                : null,
          );
        },
      ),
    )
        : const Center(child: Text('No content available'));
  }

}
