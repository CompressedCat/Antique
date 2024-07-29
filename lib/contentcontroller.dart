import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContentController extends GetxController {
  var contents = <DocumentSnapshot>[].obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    fetchContents();
  }

  Future<void> fetchContents() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('content')
          .orderBy('created_at', descending: true)
          .get();
      contents.assignAll(querySnapshot.docs);
    } catch (e) {
      print('Error fetching contents: $e');
    }
  }

  Future<void> deleteContent(String docId) async {
    try {
      await _firestore.collection('content').doc(docId).delete();
      fetchContents(); // Refresh the content list after deletion
    } catch (e) {
      print('Error deleting content: $e');
    }
  }
}
