import 'package:antiqueproject/workshop.dart';
import 'package:flutter/material.dart';
import 'ecommerce.dart'; // Import your Buy & Sell page
// Import your Repair page

class ServicePage extends StatelessWidget {
  const ServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EcommercePage()),
                );
              },
              child: const Text('Buy & Sell'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WorkshopPage()),
                );
              },
              child: const Text('Repair'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/map');
              },
              child: const Text('Location'),
            ),
          ],
        ),
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
}

