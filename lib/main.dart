// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';

// import 'firebase_options.dart';
// import 'theme.dart';
// import 'screens/signup_screen.dart';
// import 'screens/login_screen.dart';
// import 'screens/home_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Notes App',
//       theme: appTheme,
//       debugShowCheckedModeBanner: false,
//       home: const AuthGate(),
//     );
//   }
// }

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         // Show loader while checking auth state
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         // If user is not logged in → go to sign in screen
//         if (!snapshot.hasData) {
//           return const SigninScreen();
//         }

//         // If user is logged in → check if their Firestore user doc exists
//         final uid = snapshot.data!.uid;

//         return FutureBuilder<DocumentSnapshot>(
//           future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
//           builder: (context, userSnapshot) {
//             if (userSnapshot.connectionState == ConnectionState.waiting) {
//               return const Scaffold(
//                 body: Center(child: CircularProgressIndicator()),
//               );
//             }

//             if (userSnapshot.hasData && userSnapshot.data!.exists) {
//               return HomeScreen();
//             } else {
//               // If user doc does not exist, go to signup flow (DO NOT call signOut here)
//               return SignupScreen();
//             }
//           },
//         );
//       },
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart'; // <-- Don't forget this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 👤 Not logged in → show SigninScreen
        if (!snapshot.hasData) {
          return const SigninScreen();
        }

        final uid = snapshot.data!.uid;
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (userSnapshot.hasData && userSnapshot.data!.exists) {
              return HomeScreen();
            } else {
              return SignupScreen();
            }
          },
        );
      },
    );
  }
}
