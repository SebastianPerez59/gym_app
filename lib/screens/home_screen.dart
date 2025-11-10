import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Bienvenido a tu gimnasio virtual 💪',
          style: TextStyle(fontSize: 20, color: Colors.orange[800]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
