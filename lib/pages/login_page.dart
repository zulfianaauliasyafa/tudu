import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taskly/components/my_button.dart';
import 'package:taskly/components/my_button2.dart';
import 'package:taskly/components/my_textfield.dart';
import 'package:taskly/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:taskly/pages/regist_page.dart';
import 'package:taskly/pages/home_page.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key});

  void loginUser(BuildContext context) async {
    print("Login button clicked");
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      print("Empty email or password");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    try {
      FirebaseAuthService authService = FirebaseAuthService();
      final user = await authService.signInWithEmailAndPassword(email, password);
      print("User logged in: $user");

      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login failed. Check your credentials.")),
        );
      }
    } catch (e) {
      print("Error during login: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF5F7FD),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo
          SvgPicture.asset(
            'images/logo.svg',
          ),

          const SizedBox(height: 70),

          // Email TextField
          MyTextField(
            controller: emailController,
            hintText: "Email",
            obscureText: false,
          ),

          const SizedBox(height: 20),

          // Password TextField
          MyTextField(
            controller: passwordController,
            hintText: "Password",
            obscureText: true,
          ),

          const SizedBox(height: 10),

          // Forgot password?
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Lupa kata sandi?',
                  style: TextStyle(color: Color(0xFF656565)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Login button
          MyButton(
            text: "Login",
            onTap: () => loginUser(context),
          ),

          const SizedBox(height: 15),

          // Or
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    thickness: 0.5,
                    color: Color(0xFFA8A8A8),
                  ),
                ),
                SizedBox(width: 8),
                Text("atau"),
                SizedBox(width: 8),
                Expanded(
                  child: Divider(
                    thickness: 0.5,
                    color: Color(0xFFA8A8A8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // Log in with Google (future implementation)
          MyButton2(
            text: "Masuk dengan Google",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Feature not yet implemented.")),
              );
            },
          ),

          const SizedBox(height: 30),

          // Don't have an account?
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Belum memiliki akun?',
                style: TextStyle(
                  color: Color(0xFF656565),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegistPage(),
                    ),
                  );
                },
                child: const Text(
                  'Daftar',
                  style: TextStyle(
                    color: Color(0xFF4169E1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}