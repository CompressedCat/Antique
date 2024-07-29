import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'homepage.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final List<String> antiqueImages = [
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ2wR8uAW9NwmNw3hoXiTLx5TMbfeup5vEYZg&s',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRIiULvbySxZ5QemRbR3P0nKTpdvFDUyClFFQ&s',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR3PAaZ5nkPJsz9xEcWO9xaAz4lcikpWYW3Xw&s',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR9_vn1pOIqXSv55Ggzc-jsaPTYzsjLH3Jrww&s'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffc6845f), // Antique-themed background color
      body: SafeArea(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CarouselSlider(
                  options: CarouselOptions(
                    autoPlay: true,
                    aspectRatio: 2.0,
                    enlargeCenterPage: true,
                  ),
                  items: antiqueImages.map((item) => Container(
                    child: Center(
                      child: Image.network(item, fit: BoxFit.cover, width: 1000),
                    ),
                  )).toList(),
                ),
              ),
            ),
            Expanded(
              flex: 8,
              child: Container(
                width: 100,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5), // Antique-themed background color
                ),
                alignment: const AlignmentDirectional(0, -1),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 140,
                        decoration: const BoxDecoration(
                          color: Color(0xFFBFA58D), // Antique color
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(0),
                          ),
                        ),
                        alignment: const AlignmentDirectional(-1, 0),
                        child: const Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(32, 0, 0, 0),
                          child: Text(
                            'Antique Community',
                            style: TextStyle(
                              fontFamily: 'Cinzel', // Antique themed font
                              color: Color(0xFF3E2723),
                              fontSize: 36,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(0, 0),
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome Back',
                                style: TextStyle(
                                  fontFamily: 'Cinzel', // Antique themed font
                                  color: Color(0xFF3E2723),
                                  fontSize: 36,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0, 12, 0, 24),
                                child: Text(
                                  'Let\'s get started by filling out the form below.',
                                  style: TextStyle(
                                    fontFamily: 'Cinzel', // Antique themed font
                                    color: Color(0xFF6D4C41),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 0, 0, 16),
                                child: SizedBox(
                                  width: 370,
                                  child: TextFormField(
                                    controller: _emailController,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      labelStyle: const TextStyle(
                                        fontFamily: 'Cinzel', // Antique themed font
                                        color: Color(0xFF6D4C41),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 0, 0, 16),
                                child: SizedBox(
                                  width: 370,
                                  child: TextFormField(
                                    controller: _passwordController,
                                    autofocus: true,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      labelStyle: const TextStyle(
                                        fontFamily: 'Cinzel', // Antique themed font
                                        color: Color(0xFF6D4C41),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 0, 0, 16),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    String email = _emailController.text;
                                    String password = _passwordController.text;

                                    try {
                                      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                                        email: email,
                                        password: password,
                                      );
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => const HomeScreen(),
                                        ),
                                      );
                                    } catch (e) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Error'),
                                          content: Text(
                                              e is FirebaseAuthException
                                                  ? e.message ?? 'Invalid email or password. Please try again.'
                                                  : 'An unexpected error occurred. Please try again.'
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8D6E63), // Antique button color
                                    textStyle: const TextStyle(
                                      fontFamily: 'Cinzel', // Antique themed font
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  child: const Text('Sign In'),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 12, 0, 12),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).pushReplacementNamed('/signup');
                                  },
                                  child: RichText(
                                    text: const TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Don\'t have an account? ',
                                        ),
                                        TextSpan(
                                          text: 'Sign Up here',
                                          style: TextStyle(
                                            color: Color(0xFF795548),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                      style: TextStyle(
                                        fontFamily: 'Cinzel', // Antique themed font
                                        color: Color(0xFF3E2723),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
