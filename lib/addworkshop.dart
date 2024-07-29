import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddWorkshopPage extends StatelessWidget {
  const AddWorkshopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Workshop'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: _AddWorkshopForm(),
      ),
    );
  }
}

class _AddWorkshopForm extends StatefulWidget {
  const _AddWorkshopForm();

  @override
  __AddWorkshopFormState createState() => __AddWorkshopFormState();
}

class __AddWorkshopFormState extends State<_AddWorkshopForm> {
  final TextEditingController _workshopNameController = TextEditingController();
  final TextEditingController _workshopAddressController = TextEditingController();
  final TextEditingController _workshopSpecialityController = TextEditingController();
  final TextEditingController _workshopImageController = TextEditingController();
  late User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  void _addWorkshop() {
    String workshopName = _workshopNameController.text.trim();
    String workshopAddress = _workshopAddressController.text.trim();
    String workshopSpeciality = _workshopSpecialityController.text.trim();
    String workshopImage = _workshopImageController.text.trim();

    if (workshopName.isNotEmpty && workshopAddress.isNotEmpty && workshopSpeciality.isNotEmpty) {
      FirebaseFirestore.instance.collection('workshops').add({
        'workshopName': workshopName,
        'workshopAddress': workshopAddress,
        'workshopSpeciality': workshopSpeciality,
        'workshopImage': workshopImage,
        'userId': _currentUser?.uid, // User ID who added the workshop
      }).then((_) {
        Navigator.pop(context); // Close the add workshop page after successful addition
      }).catchError((error) {
        print('Failed to add workshop: $error');
        // Handle error
      });
    } else {
      // Show error message or handle empty fields
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _workshopNameController,
          decoration: const InputDecoration(
            labelText: 'Workshop Name',
          ),
        ),
        TextField(
          controller: _workshopAddressController,
          decoration: const InputDecoration(
            labelText: 'Workshop Address',
          ),
        ),
        TextField(
          controller: _workshopSpecialityController,
          decoration: const InputDecoration(
            labelText: 'Workshop Speciality',
          ),
        ),
        TextField(
          controller: _workshopImageController,
          decoration: const InputDecoration(
            labelText: 'Workshop Image URL (Optional)',
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _addWorkshop,
          child: const Text('Add Workshop'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _workshopNameController.dispose();
    _workshopAddressController.dispose();
    _workshopSpecialityController.dispose();
    _workshopImageController.dispose();
    super.dispose();
  }
}
