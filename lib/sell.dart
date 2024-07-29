import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SellPage extends StatefulWidget {
  const SellPage({super.key});

  @override
  _SellPageState createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemDescriptionController =
  TextEditingController();
  final TextEditingController _itemPriceController = TextEditingController();
  Uint8List? _selectedImageBytes;
  final picker = ImagePicker();
  String? _userId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Get the current user ID
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
      });
    } else {
      print('No image selected.');
    }
  }

  Future<void> _sellItem() async {
    final String itemName = _itemNameController.text.trim();
    final String itemDescription = _itemDescriptionController.text.trim();
    final double itemPrice = double.tryParse(_itemPriceController.text) ?? 0.0;

    // Validate input
    if (itemName.isEmpty ||
        itemDescription.isEmpty ||
        itemPrice <= 0 ||
        _selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in all fields and select an image')),
      );
      return;
    }

    // Get current user ID
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }
    final String userId = user.uid;

    setState(() {
      _isLoading = true;
    });

    // Upload image to Firebase Storage
    final Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('users')
        .child(userId)
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    final metadata = SettableMetadata(contentType: 'image/jpeg');
    final TaskSnapshot uploadTask =
    await storageRef.putData(_selectedImageBytes!, metadata);
    final String imageUrl = await uploadTask.ref.getDownloadURL();

    // Add item data to Firestore
    await FirebaseFirestore.instance.collection('items').add({
      'itemName': itemName,
      'itemDescription': itemDescription,
      'itemPrice': itemPrice,
      'imageUrl': imageUrl,
      'userId': userId,
    });

    // Reset form
    _itemNameController.clear();
    _itemDescriptionController.clear();
    _itemPriceController.clear();
    setState(() {
      _selectedImageBytes = null;
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item successfully added')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedImageBytes != null
                ? Image.memory(
              _selectedImageBytes!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            )
                : Container(
              height: 150,
              color: Colors.grey[200],
              alignment: Alignment.center,
              child: const Text('No Image Selected'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _itemNameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _itemDescriptionController,
              decoration: const InputDecoration(labelText: 'Item Description'),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _itemPriceController,
              decoration: const InputDecoration(labelText: 'Item Price (RM)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _sellItem,
              child: const Text('Sell Item'),
            ),
          ],
        ),
      ),
    );
  }
}
