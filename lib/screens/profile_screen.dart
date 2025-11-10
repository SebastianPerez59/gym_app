import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int progreso = 0;
  String plan = '';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
    await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (doc.exists) {
      setState(() {
        progreso = doc['progreso'] ?? 0;
        plan = doc['planEntrenamiento'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 100, color: Colors.orange),
            const SizedBox(height: 10),
            Text(user?.email ?? 'Sin correo', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Plan: $plan', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Progreso mensual: $progreso rutinas completadas',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
