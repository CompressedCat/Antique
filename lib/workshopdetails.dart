import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart';
import 'repairform.dart';
import 'mappage.dart';

class WorkshopDetailsPage extends StatefulWidget {
  final String workshopUid;

  WorkshopDetailsPage({
    Key? key,
    required this.workshopUid,
  }) : super(key: key);

  @override
  _WorkshopDetailsPageState createState() => _WorkshopDetailsPageState();
}

class _WorkshopDetailsPageState extends State<WorkshopDetailsPage> {
  Map<String, dynamic>? _workshopData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWorkshopData();
  }

  Future<void> _fetchWorkshopData() async {
    try {
      DocumentSnapshot workshopDoc = await FirebaseFirestore.instance
          .collection('workshops')
          .doc(widget.workshopUid)
          .get();

      setState(() {
        _workshopData = workshopDoc.data() as Map<String, dynamic>?;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching workshop data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFBFA58D), // Antique color
        title: _workshopData != null
            ? Text(
          _workshopData!['workshopName'],
          style: TextStyle(
            fontFamily: 'Cinzel', // Antique themed font
            color: Color(0xFF3E2723),
          ),
        )
            : Text(
          'Workshop Details',
          style: TextStyle(
            fontFamily: 'Cinzel', // Antique themed font
            color: Color(0xFF3E2723),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    otherUserId: _workshopData!['userId'],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _workshopData == null
          ? Center(child: Text('No data found'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Address: ${_workshopData!['workshopAddress']}',
              style: TextStyle(
                fontFamily: 'Cinzel', // Antique themed font
                color: Color(0xFF3E2723),
              ),
            ),
            Text(
              'Speciality: ${_workshopData!['workshopSpeciality']}',
              style: TextStyle(
                fontFamily: 'Cinzel', // Antique themed font
                color: Color(0xFF3E2723),
              ),
            ),
            Text(
              'Image URL: ${_workshopData!['workshopImage']}',
              style: TextStyle(
                fontFamily: 'Cinzel', // Antique themed font
                color: Color(0xFF3E2723),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RepairFormPage(
                      workshopName: _workshopData!['workshopName'],
                      workshopUid: widget.workshopUid,
                    ),
                  ),
                );
              },
              child: Text('Request Repair Price'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapPage(
                      workshopAddress: _workshopData!['workshopAddress'],
                    ),
                  ),
                );
              },
              child: Text('Find Location on Map'),
            ),
          ],
        ),
      ),
    );
  }
}
