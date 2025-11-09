import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // para formatear fechas

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(GymApp());
}

class GymApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return PlanSelectionScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}

// ---------- LOGIN Y REGISTRO ----------
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLogin = true;

  Future<void> handleAuth() async {
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(isLogin ? "Iniciar sesión" : "Registrarse",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
              TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: "Contraseña")),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: handleAuth,
                child: Text(isLogin ? "Entrar" : "Crear cuenta"),
              ),
              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(isLogin ? "¿No tienes cuenta? Regístrate" : "¿Ya tienes cuenta? Inicia sesión"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- SELECCIÓN DE PLAN ----------
class PlanSelectionScreen extends StatelessWidget {
  final plans = ["Ganar fuerza", "Ganar masa muscular", "Perder peso"];

  Future<void> selectPlan(String plan, BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser!;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final docSnap = await userDoc.get();

    final now = DateTime.now();
    final monthKey = DateFormat('yyyy-MM').format(now);

    // Verifica si ya tiene rutina del mes actual
    if (docSnap.exists && docSnap.data()!['lastRoutineMonth'] == monthKey) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => RoutineScreen(plan: plan)));
      return;
    }

    // Crear nueva rutina
    await userDoc.set({
      'plan': plan,
      'startDate': now.toIso8601String(),
      'lastRoutineMonth': monthKey,
    });

    // Guardar rutinas por semanas en subcolección
    final routineRef = userDoc.collection('routines');
    final planRoutines = RoutineGenerator.generate(plan);
    for (int i = 0; i < 4; i++) {
      await routineRef.doc('week${i + 1}').set({
        'exercises': planRoutines[i],
      });
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => RoutineScreen(plan: plan)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Selecciona tu plan")),
      body: ListView(
        children: plans
            .map((plan) => ListTile(
          title: Text(plan),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () => selectPlan(plan, context),
        ))
            .toList(),
      ),
    );
  }
}

// ---------- GENERACIÓN DE RUTINAS ----------
class RoutineGenerator {
  static List<List<String>> generate(String plan) {
    final routines = {
      "Ganar fuerza": [
        ["Sentadillas", "Peso muerto", "Press banca", "Dominadas"],
        ["Zancadas", "Press militar", "Remo con barra", "Fondos"],
        ["Sentadilla frontal", "Peso muerto sumo", "Press inclinado", "Curl bíceps"],
        ["Sentadillas", "Press banca", "Peso muerto", "Dominadas"]
      ],
      "Ganar masa muscular": [
        ["Press militar", "Curl bíceps", "Tríceps polea", "Remo barra"],
        ["Press inclinado", "Curl martillo", "Extensión de piernas", "Elevaciones laterales"],
        ["Press banca", "Curl barra", "Fondos", "Pull-over"],
        ["Remo sentado", "Extensión tríceps", "Curl concentrado", "Elevaciones frontales"]
      ],
      "Perder peso": [
        ["Cardio HIIT", "Burpees", "Plancha", "Mountain climbers"],
        ["Saltar la cuerda", "Flexiones", "Abdominales", "Bicicleta estática"],
        ["Cardio", "Escaladores", "Jump squats", "Planchas laterales"],
        ["Correr 30 min", "Burpees", "Sentadillas", "Abdominales"]
      ]
    };
    return routines[plan] ?? [];
  }
}

// ---------- PANTALLA DE RUTINA ----------
class RoutineScreen extends StatefulWidget {
  final String plan;
  RoutineScreen({required this.plan});

  @override
  _RoutineScreenState createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  int currentWeek = 0;
  late DateTime startDate;

  @override
  void initState() {
    super.initState();
    _loadStartDate();
  }

  Future<void> _loadStartDate() async {
    final user = FirebaseAuth.instance.currentUser!;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    startDate = DateTime.parse(doc['startDate']);
    setState(() {});
  }

  bool _canAccessWeek(int weekNumber) {
    final now = DateTime.now();
    final diffDays = now.difference(startDate).inDays;
    final weekUnlocked = (diffDays ~/ 7) + 1; // Cada 7 días se desbloquea una semana
    return weekNumber <= weekUnlocked;
  }

  @override
  Widget build(BuildContext context) {
    final planRoutines = RoutineGenerator.generate(widget.plan);

    return Scaffold(
      appBar: AppBar(title: Text("Rutina mensual - ${widget.plan}")),
      body: planRoutines.isEmpty
          ? Center(child: Text("No hay rutina disponible"))
          : ListView.builder(
        itemCount: 4,
        itemBuilder: (context, index) {
          final locked = !_canAccessWeek(index + 1);
          return Card(
            margin: EdgeInsets.all(12),
            color: locked ? Colors.grey[300] : Colors.white,
            child: ListTile(
              title: Text("Semana ${index + 1}"),
              subtitle: Text(planRoutines[index].join(", ")),
              trailing: locked
                  ? Icon(Icons.lock, color: Colors.grey)
                  : Icon(Icons.fitness_center, color: Colors.green),
            ),
          );
        },
      ),
    );
  }
}
