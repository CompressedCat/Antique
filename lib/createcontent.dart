import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CreateContentPage extends StatefulWidget {
  final DocumentSnapshot? existingContent;

  const CreateContentPage({Key? key, this.existingContent}) : super(key: key);

  @override
  _CreateContentPageState createState() => _CreateContentPageState();
}

class _CreateContentPageState extends State<CreateContentPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  GlobalKey<FormState> _formKey = GlobalKey();

  CollectionReference _reference = FirebaseFirestore.instance.collection('content');

  Uint8List? _selectedImageBytes;
  late String _username;
  String? _currentUserUsername;
  String? imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUserUsername();
    if (widget.existingContent != null) {
      _initializeFormWithExistingContent();
    }
  }

  Future<void> _getCurrentUserUsername() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final userData = await _firestore.collection('Users').doc(currentUser.uid).get();
      setState(() {
        _currentUserUsername = userData['username'];
        _username = userData['username'];
      });
    }
  }

  void _initializeFormWithExistingContent() {
    final contentData = widget.existingContent!.data() as Map<String, dynamic>;
    _titleController.text = contentData['title'] ?? '';
    _contentController.text = contentData['content'] ?? '';
    imageUrl = contentData['image_url'];
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _isLoading = true;
      });

      final uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

      final metadata = SettableMetadata(contentType: 'image/jpeg');

      final referenceRoot = FirebaseStorage.instance.ref();
      final referenceDirImages = referenceRoot.child('images');
      final referenceImageToUpload = referenceDirImages.child('$uniqueFileName.jpg');

      try {
        await referenceImageToUpload.putData(bytes, metadata);
        final downloadUrl = await referenceImageToUpload.getDownloadURL();
        setState(() {
          imageUrl = downloadUrl;
          _isLoading = false;
        });
        print('Image URL: $imageUrl'); // Debug statement
      } catch (error) {
        print('Error uploading image: $error');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to upload image')));
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createOrUpdateContent() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not logged in')));
      return;
    }

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title is empty')));
      return;
    }
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Content is empty')));
      return;
    }

    final contentData = {
      'title': title,
      'content': content,
      'username': _currentUserUsername ?? 'Unknown User',
      'user_id': currentUser.uid,
      'created_at': FieldValue.serverTimestamp(),
    };

    if (imageUrl != null) {
      contentData['image_url'] = imageUrl!;
    }

    if (_formKey.currentState!.validate()) {
      try {
        if (widget.existingContent == null) {
          // Create new content
          await _reference.add(contentData);
        } else {
          // Update existing content
          await _reference.doc(widget.existingContent!.id).update(contentData);
        }

        // Navigate back to the homepage
        Navigator.pop(context);
      } catch (error) {
        print('Error creating/updating content: $error');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save content')));
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFBFA58D), // Antique color
        title: Text(widget.existingContent == null ? 'Create Content' : 'Edit Content'),
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
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                maxLines: 1,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Title (Max 100 characters)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                maxLines: null,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Content (Max 500 characters)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const CircularProgressIndicator()
                  : _selectedImageBytes != null
                  ? Image.memory(
                _selectedImageBytes!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.contain,
              )
                  : imageUrl != null
                  ? CachedNetworkImage(
                imageUrl: imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.contain,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )
                  : Container(
                height: 100,
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: const Text('No Image Selected'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _createOrUpdateContent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8D6E63), // Antique button color
                    ),
                    child: Text(widget.existingContent == null ? 'Create Content' : 'Update Content'),
                  ),
                ],
              ),
            ],
          ),
        ),
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
