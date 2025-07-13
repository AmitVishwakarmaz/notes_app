import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final Color primaryColor = const Color(0xFF7CBA3B);

  bool _isLoading = false;

  Future<void> _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Passwords do not match'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final User? user = await _authService.createUserWithEmailAndPassword(
        email,
        password,
      );

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signup failed: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signupWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final User? user = await _authService.signInWithGoogle();

      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!doc.exists) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'email': user.email,
            'createdAt': FieldValue.serverTimestamp(),
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Account already exists. Please sign in.'),
              backgroundColor: Colors.redAccent,
            ),
          );
          await _authService.signOut();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-Up failed: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Colors.grey[400]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: const Color(0xFF121212),
            labelStyle: const TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text('Create Account',
                  style: GoogleFonts.roboto(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text('Sign up to get started',
                  style: GoogleFonts.roboto(color: Colors.grey[400])),
              const SizedBox(height: 40),
              _textField(
                label: 'Email',
                controller: _emailController,
                icon: Icons.email,
              ),
              _textField(
                label: 'Password',
                controller: _passwordController,
                icon: Icons.lock,
                obscure: true,
              ),
              _textField(
                label: 'Confirm Password',
                controller: _confirmPasswordController,
                icon: Icons.lock_outline,
                obscure: true,
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Sign Up', style: GoogleFonts.roboto(fontSize: 16)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[700])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child:
                        Text("OR", style: TextStyle(color: Colors.grey[400])),
                  ),
                  Expanded(child: Divider(color: Colors.grey[700])),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _signupWithGoogle,
                icon: Image.asset('assets/images/google.png', height: 24),
                label: Text(
                  'Continue with Google',
                  style: GoogleFonts.roboto(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const SigninScreen()));
                },
                child: Text('Already have an account? Sign in',
                    style: GoogleFonts.roboto(color: primaryColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
