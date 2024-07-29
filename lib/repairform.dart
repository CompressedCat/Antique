import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;

class RepairFormPage extends StatelessWidget {
  final String workshopName;
  final String workshopUid;

  const RepairFormPage({
    super.key,
    required this.workshopName,
    required this.workshopUid,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFBFA58D), // Antique color
        title: const Text('Repair Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _RepairForm(
          workshopName: workshopName,
          workshopUid: workshopUid,
        ),
      ),
    );
  }
}

class _RepairForm extends StatefulWidget {
  final String workshopName;
  final String workshopUid;

  const _RepairForm({
    required this.workshopName,
    required this.workshopUid,
  });

  @override
  __RepairFormState createState() => __RepairFormState();
}

class __RepairFormState extends State<_RepairForm> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemDescriptionController = TextEditingController();
  final TextEditingController _damageDescriptionController = TextEditingController();
  Uint8List? _webImage;
  io.File? _image;
  bool _isLoading = false;
  late User? currentUser;
  late String _username = '';

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(currentUser!.uid).get();
      setState(() {
        _username = userDoc['username'] ?? 'Anonymous';
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
        });
      } else {
        setState(() {
          _image = io.File(pickedFile.path);
        });
      }
    }
  }

  Future<String> _uploadImage(Uint8List imageBytes, String filename) async {
    final storageRef = FirebaseStorage.instance.ref().child('repair_images/$filename');
    final uploadTask = storageRef.putData(imageBytes);
    final taskSnapshot = await uploadTask.whenComplete(() => null);
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<String> _uploadImageFile(io.File imageFile) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('repair_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = storageRef.putFile(imageFile);
    final taskSnapshot = await uploadTask.whenComplete(() => null);
    return await taskSnapshot.ref.getDownloadURL();
  }

  void _submitRepairForm() async {
    String itemName = _itemNameController.text.trim();
    String itemDescription = _itemDescriptionController.text.trim();
    String damageDescription = _damageDescriptionController.text.trim();

    if (itemName.isNotEmpty &&
        itemDescription.isNotEmpty &&
        damageDescription.isNotEmpty &&
        currentUser != null) {
      setState(() {
        _isLoading = true;
      });

      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImageFile(_image!);
      } else if (_webImage != null) {
        final filename = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        imageUrl = await _uploadImage(_webImage!, filename);
      }

      FirebaseFirestore.instance.collection('repairPriceForms').add({
        'itemName': itemName,
        'itemDescription': itemDescription,
        'damageDescription': damageDescription,
        'userName': _username,
        'userUid': currentUser!.uid,
        'workshopName': widget.workshopName,
        'workshopUid': widget.workshopUid,
        'imageUrl': imageUrl, // Add image URL to the Firestore document
      }).then((_) {
        Navigator.pop(context); // Close the repair form page after successful submission
      }).catchError((error) {
        print('Failed to submit repair form: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit repair form: $error')),
        );
      }).whenComplete(() {
        setState(() {
          _isLoading = false;
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _itemNameController,
            maxLines: 1,
            maxLength: 100,
            decoration: const InputDecoration(
              labelText: 'Item Name (Max 100 characters)',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _itemDescriptionController,
            maxLines: null,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: 'Item Description (Max 500 characters)',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _damageDescriptionController,
            maxLines: null,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: 'Damage Description (Max 500 characters)',
            ),
          ),
          const SizedBox(height: 20),
          _webImage != null
              ? Image.memory(
            _webImage!,
            height: 200,
          )
              : (_image != null
              ? Image.file(
            _image!,
            height: 200,
          )
              : Container(
            height: 100,
            color: Colors.grey[200],
            alignment: Alignment.center,
            child: const Text('No Image Selected'),
          )),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
              ),
              const SizedBox(width: 16),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _submitRepairForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8D6E63), // Antique button color
                ),
                child: const Text('Submit Repair Form'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _damageDescriptionController.dispose();
    super.dispose();
  }
}
