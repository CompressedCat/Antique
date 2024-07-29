import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RepairFormDetailsPage extends StatelessWidget {
  final String formId;

  const RepairFormDetailsPage({super.key, required this.formId});

  Future<DocumentSnapshot> _getRepairFormDetails() async {
    return await FirebaseFirestore.instance.collection('repairPriceForms').doc(formId).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFBFA58D), // Antique color
        title: const Text('Repair Form Details', style: TextStyle(fontFamily: 'Cinzel')),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _getRepairFormDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}', style: const TextStyle(fontFamily: 'Cinzel')),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Form not found', style: TextStyle(fontFamily: 'Cinzel')),
            );
          }

          final formData = snapshot.data!.data() as Map<String, dynamic>;
          final itemName = formData['itemName'];
          final itemDescription = formData['itemDescription'];
          final damageDescription = formData['damageDescription'];
          final imageUrl = formData['imageUrl'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Item Name:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cinzel')),
                const SizedBox(height: 4),
                Text(itemName, style: const TextStyle(fontSize: 16, fontFamily: 'Cinzel')),
                const SizedBox(height: 10),
                Text('Item Description:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cinzel')),
                const SizedBox(height: 4),
                Text(itemDescription, style: const TextStyle(fontSize: 16, fontFamily: 'Cinzel')),
                const SizedBox(height: 10),
                Text('Damage Description:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cinzel')),
                const SizedBox(height: 4),
                Text(damageDescription, style: const TextStyle(fontSize: 16, fontFamily: 'Cinzel')),
                const SizedBox(height: 10),
                Text('Image:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cinzel')),
                const SizedBox(height: 10),
                imageUrl != null
                    ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                )
                    : Container(
                  height: 200,
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: const Text('No Image Available', style: TextStyle(fontFamily: 'Cinzel')),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}