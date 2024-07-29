import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_page.dart';

class OtherUserProfilePage extends StatefulWidget {
  final String profileUserId;

  const OtherUserProfilePage({Key? key, required this.profileUserId}) : super(key: key);

  @override
  _OtherUserProfilePageState createState() => _OtherUserProfilePageState();
}

class _OtherUserProfilePageState extends State<OtherUserProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _userInfo;
  List<DocumentSnapshot<Object?>> _userContents = [];

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _fetchUserContents();
  }

  Future<void> _fetchUserInfo() async {
    try {
      DocumentSnapshot<Object?> userDoc = await _firestore
          .collection('Users')
          .doc(widget.profileUserId)
          .get();
      setState(() {
        _userInfo = userDoc.data() as Map<String, dynamic>?;
      });
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }

  Future<void> _fetchUserContents() async {
    try {
      QuerySnapshot<Object?> querySnapshot = await _firestore
          .collection('content')
          .where('user_id', isEqualTo: widget.profileUserId)
          .orderBy('created_at', descending: false) // Sorting by FIFO
          .get();
      setState(() {
        _userContents = querySnapshot.docs;
      });
    } catch (e) {
      print('Error fetching user contents: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFBFA58D), // Antique color
        title: const Text('Other User\'s Profile', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                'User\'s Content',
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(otherUserId: widget.profileUserId),
                  ),
                );
              },
              child: const Text('Chat with User'),
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
          var contentData = _userContents[index].data() as Map<String, dynamic>;
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
                      ? (contentData['created_at'] as Timestamp).toDate().toString()
                      : '',
                ),
              ],
            ),
          );
        },
      ),
    )
        : const Center(child: Text('No content available'));
  }


}
