import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  String plan = '';
  int progreso = 0;
  bool cargando = true;

  final user = FirebaseAuth.instance.currentUser;

  // Rutinas predefinidas según el plan elegido
  final Map<String, Map<String, List<String>>> rutinasPorPlan = {
    'Ganar masa muscular 💪': {
      'Monday': ['Pecho y tríceps pesados', 'Press banca', 'Fondos'],
      'Tuesday': ['Espalda y bíceps', 'Dominadas', 'Remo con barra'],
      'Wednesday': ['Piernas', 'Sentadillas', 'Peso muerto'],
      'Thursday': ['Hombros', 'Press militar', 'Elevaciones laterales'],
      'Friday': ['Brazos', 'Curl biceps', 'Press francés'],
      'Saturday': ['Descanso activo'],
      'Sunday': ['Descanso'],
    },
    'Perder peso 🏃‍♂️': {
      'Monday': ['Cardio HIIT 30 min', 'Abdominales'],
      'Tuesday': ['Full body ligero', 'Circuito funcional'],
      'Wednesday': ['Descanso activo', 'Caminar 40 min'],
      'Thursday': ['Cardio bicicleta', 'Plancha 3x1min'],
      'Friday': ['Full body + cardio'],
      'Saturday': ['Caminata ligera'],
      'Sunday': ['Descanso'],
    },
    'Ganar fuerza 🏋️‍♀️': {
      'Monday': ['Sentadillas pesadas', 'Peso muerto'],
      'Tuesday': ['Press banca 5x5', 'Dominadas lastradas'],
      'Wednesday': ['Descanso activo'],
      'Thursday': ['Press militar', 'Remo pesado'],
      'Friday': ['Trabajo de core', 'Farmer walk'],
      'Saturday': ['Estiramientos'],
      'Sunday': ['Descanso'],
    },
  };

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  // Cargar plan y progreso del usuario desde Firestore
  Future<void> _cargarDatosUsuario() async {
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        plan = doc['planEntrenamiento'] ?? '';
        progreso = doc['progreso'] ?? 0;
      }
    } catch (e) {
      debugPrint('Error cargando datos: $e');
    }
    setState(() => cargando = false);
  }

  // Marcar rutina como completada y guardar progreso
  Future<void> _marcarComoCompletado() async {
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'progreso': progreso + 1,
        'ultimaFecha': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Rutina completada!')),
      );

      setState(() {
        progreso++;
      });
    } catch (e) {
      debugPrint('Error actualizando progreso: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final now = DateTime.now();
    final hoyIngles = DateFormat('EEEE').format(now);
    final hoy = hoyIngles[0].toUpperCase() + hoyIngles.substring(1); // "Monday"

    final rutinasHoy = rutinasPorPlan[plan]?[hoy] ?? ['Día de descanso'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Rutina del día ($plan)'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hoy es $hoy',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...rutinasHoy.map((r) => Card(
              elevation: 3,
              child: ListTile(
                title: Text(r),
                leading:
                const Icon(Icons.fitness_center, color: Colors.orange),
              ),
            )),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: _marcarComoCompletado,
                icon: const Icon(Icons.check),
                label: const Text('Marcar como completada'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Rutinas completadas este mes: $progreso',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
