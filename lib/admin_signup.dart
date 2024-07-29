import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSignUpPage extends StatefulWidget {
  const AdminSignUpPage({super.key});

  @override
  _AdminSignUpPageState createState() => _AdminSignUpPageState();
}

class _AdminSignUpPageState extends State<AdminSignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _passwordVisible = false;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _signUp() async {
    if (!_validateFields()) {
      return;
    }

    try {
      final newUser = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (newUser.user != null) {
        final userDoc = _firestore.collection('Users').doc(newUser.user!.uid);
        await userDoc.set({
          'username': _usernameController.text.trim(),
          'phone_number': _phoneNumberController.text.trim(),
          'email': _emailController.text.trim(),
          'user_type': 'admin',
          'created_at': FieldValue.serverTimestamp(),
        });

        // Navigate to the login page
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      print('Error signing up: $e');
      _showErrorDialog('Sign Up Failed', e.toString());
    }
  }

  bool _validateFields() {
    if (_usernameController.text.trim().isEmpty) {
      _showErrorDialog('Invalid Input', 'Username cannot be empty.');
      return false;
    }

    if (_phoneNumberController.text.trim().isEmpty) {
      _showErrorDialog('Invalid Input', 'Phone number cannot be empty.');
      return false;
    }

    if (_emailController.text.trim().isEmpty || !_emailController.text.contains('@')) {
      _showErrorDialog('Invalid Input', 'Please enter a valid email address.');
      return false;
    }

    if (_passwordController.text.trim().length < 6) {
      _showErrorDialog('Invalid Input', 'Password must be at least 6 characters long.');
      return false;
    }

    return true;
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void navigateToUserSignUp() {
    Navigator.of(context).pushReplacementNamed('/signup');
  }

  void navigateToVendorSignUp() {
    Navigator.of(context).pushReplacementNamed('/vendor_signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFBFA58D), // Antique color
        title: const Text(
          'Admin Sign Up',
          style: TextStyle(
            fontFamily: 'Cinzel', // Antique themed font
            color: Color(0xFF3E2723),
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFFF5F5F5), // Antique-themed background color
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: const TextStyle(
                    fontFamily: 'Cinzel', // Antique themed font
                    color: Color(0xFF6D4C41),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF8D6E63),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF795548),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                ),
                style: const TextStyle(
                  fontFamily: 'Cinzel', // Antique themed font
                  color: Color(0xFF3E2723),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: const TextStyle(
                    fontFamily: 'Cinzel', // Antique themed font
                    color: Color(0xFF6D4C41),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF8D6E63),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF795548),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                ),
                style: const TextStyle(
                  fontFamily: 'Cinzel', // Antique themed font
                  color: Color(0xFF3E2723),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(
                    fontFamily: 'Cinzel', // Antique themed font
                    color: Color(0xFF6D4C41),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF8D6E63),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF795548),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                ),
                style: const TextStyle(
                  fontFamily: 'Cinzel', // Antique themed font
                  color: Color(0xFF3E2723),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(
                    fontFamily: 'Cinzel', // Antique themed font
                    color: Color(0xFF6D4C41),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF8D6E63),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF795548),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Color(0xFF6D4C41),
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_passwordVisible,
                style: const TextStyle(
                  fontFamily: 'Cinzel', // Antique themed font
                  color: Color(0xFF3E2723),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8D6E63), // Antique button color
                  textStyle: const TextStyle(
                    fontFamily: 'Cinzel', // Antique themed font
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: navigateToUserSignUp,
                    icon: Icon(Icons.person_outline),
                    tooltip: 'User Sign Up',
                  ),
                  IconButton(
                    onPressed: navigateToVendorSignUp,
                    icon: Icon(Icons.storefront_outlined),
                    tooltip: 'Vendor Sign Up',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: const Text(
                  'Already have an account? Sign in',
                  style: TextStyle(
                    fontFamily: 'Cinzel', // Antique themed font
                    color: Color(0xFF4B39EF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
