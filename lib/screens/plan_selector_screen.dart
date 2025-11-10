import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_screen.dart';

class PlanSelectorScreen extends StatelessWidget {
  const PlanSelectorScreen({super.key});

  Future<void> _guardarPlan(BuildContext context, String plan) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'planEntrenamiento': plan,
      'progreso': 0,
      'ultimaFecha': DateTime.now().toIso8601String(),
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final planes = [
      'Ganar masa muscular 💪',
      'Perder peso 🏃‍♂️',
      'Ganar fuerza 🏋️‍♀️',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Elige tu plan de entrenamiento')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: planes
              .map((plan) => Card(
            elevation: 3,
            child: ListTile(
              title: Text(plan),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _guardarPlan(context, plan),
            ),
          ))
              .toList(),
        ),
      ),
    );
  }
}
