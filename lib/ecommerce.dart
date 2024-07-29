import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EcommercePage extends StatefulWidget {
  const EcommercePage({super.key});

  @override
  _EcommercePageState createState() => _EcommercePageState();
}

class _EcommercePageState extends State<EcommercePage> {
  late TextEditingController _searchController;
  late bool _sortAscending;
  late Stream<QuerySnapshot> _itemsStream;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _sortAscending = true;
    _itemsStream = FirebaseFirestore.instance.collection('items').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: _searchItems,
            ),
          ),
          onSubmitted: (_) => _searchItems(),
        ),
        actions: [
          IconButton(
            icon: Icon(_sortAscending ? Icons.sort_by_alpha : Icons.sort_by_alpha_outlined),
            onPressed: _sortItems,
          ),
          IconButton(
            icon: const Icon(Icons.sell),
            onPressed: () {
              Navigator.pushNamed(context, '/sell');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _itemsStream,
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

          final items = snapshot.data?.docs ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Text('No items found.'),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final itemName = item['itemName'];
              final itemDescription = item['itemDescription'];
              final itemImage = item['itemImage'];
              final itemPrice = item['itemPrice'];

              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DisplayItemPage(
                        itemName: itemName,
                        itemDescription: itemDescription,
                        itemImage: itemImage,
                        itemPrice: itemPrice,
                      ),
                    ),
                  );
                },
                leading: CachedNetworkImage(
                  imageUrl: itemImage,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                title: Text(itemName),
                subtitle: Text(itemDescription),
                trailing: Text('RM $itemPrice'),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_back, color: Colors.black), // Back button
            label: 'Back',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build, color: Colors.black),
            label: 'Service',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pop(context); // Go back to the previous page
              break;
            case 1:
              Navigator.pushNamed(context, '/homepage'); // Navigate to Home page
              break;
            case 2:
              Navigator.pushNamed(context, '/profile'); // Navigate to Profile page
              break;
            case 3:
              Navigator.pushNamed(context, '/service'); // Navigate to Service page
              break;
          }
        },
      ),
    );
  }

  void _searchItems() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        _itemsStream = FirebaseFirestore.instance
            .collection('items')
            .where('itemName', isGreaterThanOrEqualTo: query)
            .where('itemName', isLessThanOrEqualTo: '$query\uf8ff')
            .snapshots();
      });
    } else {
      setState(() {
        _itemsStream = FirebaseFirestore.instance.collection('items').snapshots();
      });
    }
  }

  void _sortItems() {
    setState(() {
      _sortAscending = !_sortAscending;
      _itemsStream = FirebaseFirestore.instance
          .collection('items')
          .orderBy('itemPrice', descending: !_sortAscending)
          .snapshots();
    });
  }
}

class DisplayItemPage extends StatelessWidget {
  final String itemName;
  final String itemDescription;
  final String itemImage;
  final int itemPrice;

  const DisplayItemPage({
    super.key,
    required this.itemName,
    required this.itemDescription,
    required this.itemImage,
    required this.itemPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: itemImage,
              fit: BoxFit.cover,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    itemDescription,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Price: RM $itemPrice',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
