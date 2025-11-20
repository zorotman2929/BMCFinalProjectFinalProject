import 'package:ecommerce_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. Add Firebase Auth import
import 'package:cloud_firestore/cloud_firestore.dart'; // 1. ADD THIS IMPORT

// 1. Create a StatefulWidget
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

// 2. This is the State class
class _SignUpScreenState extends State<SignUpScreen> {
  // 3. Create a GlobalKey for the Form
  final _formKey = GlobalKey<FormState>();

  // 4. Create TextEditingControllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 2. Add loading state and auth instance
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // 2. ADD THIS

  // 5. Clean up controllers when the widget is removed
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    // 1. This part is the same: validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // 2. This is the same: set loading to true
    setState(() {
      _isLoading = true;
    });

    try {
      // 3. This is the same: create the user
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // 4. --- THIS IS THE NEW PART ---
      // After creating the user, save their info to Firestore
      if (userCredential.user != null) {
        // 5. Create a document in a 'users' collection
        //    We use the user's unique UID as the document ID
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': _emailController.text.trim(),
          'role': 'user', // 6. Set the default role to 'user'
          'createdAt': FieldValue.serverTimestamp(), // For our records
        });
      }
      // 7. The AuthWrapper will handle navigation automatically
      // ...
    } on FirebaseAuthException catch (e) {
      // ... (your existing error handling)
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('eCommerce')),

      // Center the entire form
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 280,
                maxWidth: screenWidth < 500 ? screenWidth : 400,
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min, // keeps the column compact
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🟦 1. Big "Login" title
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 36, // big and bold
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32), // space below title
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Sign Up button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(
                        50,
                      ), // make button full width
                    ),
                    onPressed: _signUp,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                        : const Text('Sign Up'),
                  ),

                  const SizedBox(height: 10),

                  // "Already have an account?" link
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text("Already have an account? Login"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
