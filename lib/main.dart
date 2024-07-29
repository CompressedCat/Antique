import 'dart:io';
import 'package:antiqueproject/admin_signup.dart';
import 'package:antiqueproject/vendor_signup.dart';

import 'chat_page.dart';
import 'chatlist.dart';
import 'map_interface.dart';
import 'workshop.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'contentdetailpage.dart';
import 'createcontent.dart';
import 'homepage.dart';
import 'profilepage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login.dart';
import 'signup.dart';
import 'service.dart';
import 'ecommerce.dart';
import 'sell.dart';
import 'mappage.dart';
import 'mobile_map.dart';
import 'web_map.dart';
// Import Firebase Core
// Import Firebase Storage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // Provide your Firebase options here
    options: kIsWeb || Platform.isWindows || Platform.isAndroid
        ? const FirebaseOptions(
      apiKey: 'AIzaSyAG5jFLsrlFeZ1ictxF4sBdLDuCbc1D4ms',
      appId: '1:498461764225:android:9dec7cb6885bd460a83b80',
      messagingSenderId: '498461764225',
      projectId: 'antiqueproject-646c2',
      storageBucket: 'antiqueproject-646c2.appspot.com',
      measurementId: "G-TZCFN8X2PH",
      authDomain: "antiqueproject-646c2.firebaseapp.com",
    )
        : null,
  );

  // Set the publishable key for Stripe
  // Stripe.publishableKey = "pk_test_51PID41COKFFHfrTywgfxeQmXvt80W5fI6zCxpuJoq29z7dCI4he0pqp2mTNcBLOYCzi0di4qY98ousNXQDDpU8YG00WnMsNncK";
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Antique Community',
      debugShowCheckedModeBanner: false, // Set this to false to hide the debug banner
      initialRoute: '/signup',
      routes: {
        '/signup': (context) => const SignUpPage(),
        '/admin_signup': (context) => const AdminSignUpPage(),
        '/vendor_signup': (context) => const VendorSignUpPage(),
        '/login': (context) => const LoginWidget(),
        '/homepage': (context) => HomeScreen(),
        '/create_content': (context) => const CreateContentPage(),
        '/service': (context) => const ServicePage(),
        '/ecommerce': (context) => const EcommercePage(),
        '/sell': (context) => const SellPage(),
        '/map': (context) => const MapPage(),
        '/profile': (context) => const ProfilePage(),
        '/content_detail': (context) =>
            ContentDetailPage(contentSnapshot: ModalRoute.of(context)!.settings.arguments as DocumentSnapshot<Object?>),
        '/workshops': (context) => const WorkshopPage(),
        '/chat': (context) => ChatPage(otherUserId: ModalRoute.of(context)!.settings.arguments as String),
        '/chatlist': (context) => ChatListPage(), // Updated route
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/content_detail') {
          // Extract arguments and pass them to ContentDetailPage
          final args = settings.arguments as DocumentSnapshot<Object?>?;
          return MaterialPageRoute(
            builder: (context) => ContentDetailPage(contentSnapshot: args!),
          );
        }
        return null;
        // Handle other routes if needed
      },
    );
  }
}
