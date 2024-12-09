import 'package:flutter/material.dart';

class MyButton2 extends StatelessWidget {
  final Function()? onTap;
  final String text;
  
  const MyButton2({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Color(0xFF4169E1),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/google_logo.png',  
              height: 24,
              width: 24,
            ),

            const SizedBox(width: 15),

            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF4169E1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}