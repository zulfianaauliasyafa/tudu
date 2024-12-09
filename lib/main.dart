import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskly/pages/addtask_page.dart';
import 'package:taskly/pages/home_page.dart';
import 'package:taskly/pages/regist_page.dart';
import 'pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyBpWxcYCufGfvxYjsPY8JPQ3VyPkab1QV4",
        appId: "1:391644262607:web:6b42f9f9e752c9d36e87ba",
        messagingSenderId: "391644262607",
        projectId: "project-akhir-pam-4f1a1",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // No need for `initialRoute`; determine route dynamically.
      home: AuthCheck(),
      routes: {
        '/regist': (context) => RegistPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => const HomePage(),
        '/add': (context) => AddTaskPage(),
      },
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    // Check the current user
    final User? user = FirebaseAuth.instance.currentUser;

    // Determine initial page based on authentication status
    if (user != null) {
      return const HomePage(); // User is logged in
    } else {
      return LoginPage(); // User is not logged in
    }
  }
}
