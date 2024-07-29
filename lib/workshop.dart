import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_page.dart';
import 'mappage.dart';
import 'repairformdetail.dart';
import 'workshopdetails.dart';
import 'addworkshop.dart';

class WorkshopPage extends StatefulWidget {
  const WorkshopPage({super.key});

  @override
  _WorkshopPageState createState() => _WorkshopPageState();
}

class _WorkshopPageState extends State<WorkshopPage> {
  late Stream<QuerySnapshot> _workshopsStream;
  late Stream<QuerySnapshot> _repairPriceFormsStream;
  late User? _currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String _username = '';
  late String _userType = ''; // Added to store user type

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _workshopsStream = FirebaseFirestore.instance.collection('workshops').snapshots();
    _repairPriceFormsStream = FirebaseFirestore.instance.collection('repairPriceForms').snapshots();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = _auth.currentUser;
      DocumentSnapshot userDoc = await _firestore.collection('Users').doc(user!.uid).get();
      setState(() {
        _username = userDoc['username'] ?? '';
        _userType = userDoc['user_type'] ?? ''; // Fetch and store user type
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  bool isWorkshopRepresentative() {
    // Check if the current user is a workshop representative
    // This logic can be based on user roles or specific criteria in your application
    return _currentUser != null && _currentUser!.uid == 'workshop_representative_id';
  }

  void deleteForm(String formId) {
    FirebaseFirestore.instance.collection('repairPriceForms').doc(formId).delete().then((value) {
      print('Form deleted successfully');
    }).catchError((error) {
      print('Failed to delete form: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workshops'),
        backgroundColor: Color(0xFFBFA58D), // Antique color
        actions: [
          if (_userType == 'vendor') // Show only if user_type is 'vendor'
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddWorkshopPage(),
                  ),
                );
              },
            ),
          if (isWorkshopRepresentative())
            IconButton(
              icon: const Icon(Icons.chat),
              onPressed: () {
                // Handle chat button pressed
                // Navigate to chat page or implement chat functionality
              },
            ),
        ],
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
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFFBFA58D), // Antique color
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Workshops'),
                Tab(text: 'Repair Price Forms'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildWorkshopsList(),
              _buildRepairPriceFormsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkshopsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _workshopsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final workshops = snapshot.data?.docs ?? [];

        if (workshops.isEmpty) {
          return const Center(
            child: Text('No workshops found.'),
          );
        }

        return ListView.builder(
          itemCount: workshops.length,
          itemBuilder: (context, index) {
            final workshop = workshops[index];
            final workshopName = workshop['workshopName'];
            final workshopAddress = workshop['workshopAddress'];
            final workshopSpeciality = workshop['workshopSpeciality'];
            final workshopUid = workshop.id;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkshopDetailsPage(workshopUid: workshopUid),
                    ),
                  );
                },
                title: Text(
                  workshopName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      workshopAddress,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Speciality: $workshopSpeciality',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRepairPriceFormsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _repairPriceFormsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final forms = snapshot.data?.docs ?? [];

        if (forms.isEmpty) {
          return const Center(
            child: Text('No repair price forms found.'),
          );
        }

        return ListView.builder(
          itemCount: forms.length,
          itemBuilder: (context, index) {
            final form = forms[index];
            final itemName = form['itemName'];
            final userName = form['userName'];
            final workshopUid = form['workshopUid'];
            final userUid = form['userUid']; // The user who sent the form
            final formId = form.id;

            // Determine if current user sent this form or is the workshop representative
            bool isFormSender = _currentUser != null && _currentUser!.uid == userUid;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('workshops').doc(workshopUid).get(),
              builder: (context, workshopSnapshot) {
                if (workshopSnapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    title: Text('Loading...'),
                  );
                }

                if (!workshopSnapshot.hasData || !workshopSnapshot.data!.exists) {
                  return const ListTile(
                    title: Text('Workshop not found'),
                  );
                }

                final workshopData = workshopSnapshot.data!.data() as Map<String, dynamic>;
                final workshopName = workshopData['workshopName'];
                final workshopCreatorUid = workshopData['user_id']; // Assuming user_id is the ID of workshop creator

                bool isWorkshopRep = _currentUser != null && _currentUser!.uid == workshopCreatorUid;

                // Only show the form if the current user is the form sender or workshop representative
                if (isFormSender || isWorkshopRep) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        workshopName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            'Item: $itemName',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'User: $userName',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chat),
                            onPressed: () {
                              // Handle chat button pressed
                              // Navigate to chat page or implement chat functionality
                              // You can use workshopCreatorUid to determine who to chat with
                              // Example: Navigate to a chat screen with workshop creator
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    otherUserId: workshopCreatorUid,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RepairFormDetailsPage(formId: formId),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  // If current user is not sender or workshop representative, return an empty Container()
                  return Container();
                }
              },
            );
          },
        );
      },
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
