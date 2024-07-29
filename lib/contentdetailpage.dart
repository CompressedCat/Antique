import 'profilepage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'mappage.dart';
import 'other_user_profile_page.dart';
import 'dart:html' as html;

class ContentDetailPage extends StatefulWidget {
  final DocumentSnapshot<Object?>? contentSnapshot;

  const ContentDetailPage({Key? key, required this.contentSnapshot}) : super(key: key);

  @override
  _ContentDetailPageState createState() => _ContentDetailPageState();
}

class _ContentDetailPageState extends State<ContentDetailPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _commentController = TextEditingController();

  late String _username; // Variable to store current user's username

  @override
  void initState() {
    super.initState();
    _getCurrentUsername();
  }

  Future<void> _getCurrentUsername() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      // Fetch the username from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('Users').doc(currentUser.uid).get();
      setState(() {
        _username = userDoc['username'] ?? 'Anonymous';
      });
    } else {
      setState(() {
        _username = 'Anonymous';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var contentData = widget.contentSnapshot?.data() as Map<String, dynamic>? ?? {};
    String contentId = widget.contentSnapshot?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Detail'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.brown.shade800, // Deep shade of brown
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.black.withOpacity(0.2)), // Border for separation
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contentData['title'] ?? 'No Title',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  // Display author's username and make it clickable
                  GestureDetector(
                    onTap: () {
                      _navigateToProfile(contentData['user_id']);
                    },
                    child: Text(
                      'By: ${contentData['username'] ?? 'Unknown'}',
                      style: const TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline),
                    ),
                  ),
                  Text(
                    contentData['content'] ?? 'No Content',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      final imageUrl = contentData['image_url'];
                      if (imageUrl != null && imageUrl.isNotEmpty) {
                        html.window.open(imageUrl, 'new_tab'); // Opens in a new tab
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Image URL is not available')),
                        );
                      }
                    },
                    child: Text(
                      'Image URL: ${contentData['image_url'] ?? 'No image available'}',
                      style: const TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.brown.shade400, // Lighter shade of brown
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.black.withOpacity(0.2)), // Border for separation
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Comments',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder(
                    stream: _firestore
                        .collection('comments')
                        .where('content_id', isEqualTo: contentId)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No comments yet'));
                      } else {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var commentData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                            return ListTile(
                              title: Text(commentData['comment'] ?? ''),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (commentData['image_url'] != null)
                                    GestureDetector(
                                      onTap: () {
                                        final commentImageUrl = commentData['image_url'];
                                        if (commentImageUrl != null && commentImageUrl.isNotEmpty) {
                                          html.window.open(commentImageUrl, 'new_tab'); // Opens in a new tab
                                        }
                                      },
                                      child: Text(
                                        'Image URL: ${commentData['image_url']}',
                                        style: const TextStyle(fontSize: 14, color: Colors.blue),
                                      ),
                                    ),
                                  GestureDetector(
                                    onTap: () {
                                      _navigateToProfile(commentData['user_id']);
                                    },
                                    child: Text('By: ${commentData['username'] ?? 'Unknown'}'),
                                  ),
                                  Text('At: ${commentData['timestamp'].toDate()}'),
                                  if (_isCommentOwner(commentData['user_id']))
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () {
                                            _showEditCommentDialog(snapshot.data!.docs[index].id, commentData);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            _deleteComment(snapshot.data!.docs[index].id);
                                          },
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Post a Comment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      hintText: 'Enter your comment (500 characters max)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      _postComment(contentId);
                    },
                    child: const Text('Post Comment'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isCommentOwner(String? commentUserId) {
    final currentUser = _auth.currentUser;
    return currentUser != null && commentUserId == currentUser.uid;
  }

  void _showEditCommentDialog(String commentId, Map<String, dynamic> commentData) {
    final TextEditingController _editCommentController = TextEditingController(text: commentData['comment']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Comment'),
        content: TextField(
          controller: _editCommentController,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Enter your comment (500 characters max)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _editComment(commentId, _editCommentController.text.trim());
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editComment(String commentId, String newComment) async {
    if (newComment.isNotEmpty) {
      try {
        await _firestore.collection('comments').doc(commentId).update({'comment': newComment});
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comment updated successfully')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating comment: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comment cannot be empty')));
    }
  }

  void _deleteComment(String commentId) {
    _firestore.collection('comments').doc(commentId).delete();
  }

  void _postComment(String contentId) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      String userId = currentUser.uid;
      String username = _username ?? 'Anonymous'; // Use stored username
      String comment = _commentController.text.trim();
      if (comment.isNotEmpty) {
        // Prepare comment data
        Map<String, dynamic> commentData = {
          'user_id': userId,
          'username': username,
          'comment': comment,
          'content_id': contentId,
          'timestamp': Timestamp.now(),
        };

        // Save comment to Firestore
        await _firestore.collection('comments').add(commentData);

        // Clear the comment text field after posting
        _commentController.clear();
      } else {
        // Handle empty comment
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter a comment'),
        ));
      }
    } else {
      // Handle case where user is not authenticated
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You need to be logged in to comment'),
      ));
    }
  }

  void _logOut() async {
    try {
      await _auth.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  void _navigateToProfile(String? userId) {
    if (userId != null) {
      if (_auth.currentUser != null && _auth.currentUser!.uid == userId) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtherUserProfilePage(profileUserId: userId),
          ),
        );
      }
    }
  }
}
