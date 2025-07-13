import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Color primaryColor = const Color(0xFF7CBA3B);

  bool _isLoading = false;

  void _signin() async {
    setState(() => _isLoading = true);
    try {
      User? user = await _authService.loginUserWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => HomeScreen()));
        } else {
          await _authService.signOut();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No account found. Please sign up.'),
              backgroundColor: Colors.redAccent,
            ),
          );
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => SignupScreen()));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _signinWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      User? user = await _authService.signInWithGoogle();
      if (user != null) {
        // ✅ Double-check Firestore user profile exists
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        } else {
          await _authService.signOut();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No account found. Please sign up.'),
              backgroundColor: Colors.redAccent,
            ),
          );
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => SignupScreen()));
        }
      } else {
        // ❗ Google email not registered — redirect
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'No account found with this Google email. Please sign up.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => SignupScreen()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-in failed: $e')),
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
              Text('Welcome Back',
                  style: GoogleFonts.roboto(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text('Sign in to your account',
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
              ElevatedButton(
                onPressed: _isLoading ? null : _signin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Sign In', style: GoogleFonts.roboto(fontSize: 16)),
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
                onPressed: _isLoading ? null : _signinWithGoogle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: Image.asset('assets/images/google.png', height: 24),
                label: Text('Continue with Google',
                    style: GoogleFonts.roboto(
                        fontSize: 16, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => SignupScreen()));
                },
                child: Text('Don\'t have an account? Sign up',
                    style: GoogleFonts.roboto(color: primaryColor)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
