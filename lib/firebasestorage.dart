import 'package:firebase_storage/firebase_storage.dart';

class FirebaseDatabaseManager {
  Future<String?> getImageUrl(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) {
      return null;
    }
    try {
      // Directly return the provided image URL
      return imageUrl;
    } catch (e) {
      print('Error getting image URL: $e');
      return null;
    }
  }
}
