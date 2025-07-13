// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_ui_auth/firebase_ui_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'home_screen.dart';
// import 'forgot_password_screen.dart';
// import '../services/auth_service.dart';

// class SigninScreen extends StatefulWidget {
//   const SigninScreen({super.key});

//   @override
//   _SigninScreenState createState() => _SigninScreenState();
// }

// class _SigninScreenState extends State<SigninScreen> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   bool _obscurePassword = true;

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message, style: GoogleFonts.roboto()),
//         backgroundColor: Colors.redAccent,
//       ),
//     );
//   }

//   Future<void> signIn(BuildContext context) async {
//     try {
//       final user = await AuthService().loginUserWithEmailAndPassword(
//         emailController.text.trim(),
//         passwordController.text.trim(),
//       );
//       if (user != null) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => HomeScreen()),
//         );
//       }
//     } catch (e) {
//       _showSnackBar(e.toString());
//     }
//   }

//   Future<void> signInWithGoogle(BuildContext context) async {
//     try {
//       final user = await AuthService().signInWithGoogle();
//       if (user != null) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => HomeScreen()),
//         );
//       }
//     } catch (e) {
//       _showSnackBar(e.toString());
//     }
//   }

//   Widget _buildTextField({
//     required String label,
//     required TextEditingController controller,
//     bool obscureText = false,
//     IconData? prefixIcon,
//     Widget? suffixIcon,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       style: TextStyle(color: Colors.white),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(color: Colors.grey[400]),
//         prefixIcon: prefixIcon != null
//             ? Icon(prefixIcon, color: Colors.grey[400])
//             : null,
//         suffixIcon: suffixIcon,
//         filled: true,
//         fillColor: const Color(0xFF1E1E1E),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text("Sign In",
//                   style: GoogleFonts.roboto(fontSize: 28, color: Colors.white)),
//               const SizedBox(height: 30),
//               _buildTextField(
//                 label: 'Email',
//                 controller: emailController,
//                 prefixIcon: Icons.email,
//               ),
//               const SizedBox(height: 16),
//               _buildTextField(
//                 label: 'Password',
//                 controller: passwordController,
//                 obscureText: _obscurePassword,
//                 prefixIcon: Icons.lock,
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     _obscurePassword ? Icons.visibility_off : Icons.visibility,
//                     color: Colors.grey[400],
//                   ),
//                   onPressed: () {
//                     setState(() => _obscurePassword = !_obscurePassword);
//                   },
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () => signIn(context),
//                 child: const Text("Sign In"),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF7CBA3B),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton.icon(
//                 onPressed: () => signInWithGoogle(context),
//                 icon: Image.asset('assets/images/google.png', height: 24),
//                 label: const Text('Continue with Google'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   foregroundColor: Colors.black,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  void _showSnackBar(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.roboto()),
        backgroundColor: color ?? Colors.redAccent,
      ),
    );
  }

  Future<void> _signInWithEmailPassword() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.loginUserWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        final doc = await FirebaseFirestore.instance
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
          _showSnackBar('No account found. Please sign up.',
              color: Colors.green);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => SignupScreen()),
          );
        }
      }
    } catch (e) {
      _showSnackBar('Sign-in failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      // Sign out to always prompt account selection
      await _authService.signOutFromGoogle();

      final user = await _authService.signInWithGoogle();

      if (user != null) {
        final doc = await FirebaseFirestore.instance
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
          _showSnackBar('No account found. Please sign up.',
              color: Colors.green);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => SignupScreen()),
          );
        }
      }
    } catch (e) {
      _showSnackBar('Google Sign-in failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon:
                icon != null ? Icon(icon, color: Colors.grey[400]) : null,
            suffixIcon: suffixIcon,
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
    final primaryColor = const Color(0xFF7CBA3B);

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
              _buildTextField(
                label: 'Email',
                controller: emailController,
                icon: Icons.email,
              ),
              _buildTextField(
                label: 'Password',
                controller: passwordController,
                icon: Icons.lock,
                obscure: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[400],
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : _signInWithEmailPassword,
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
                onPressed: _isLoading ? null : () => _signInWithGoogle(),
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
                child: Text("Don't have an account? Sign up",
                    style: GoogleFonts.roboto(
                        color: primaryColor, fontWeight: FontWeight.w500)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
