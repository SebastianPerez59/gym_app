import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> registrarUsuario(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      print("Error en registro: $e");
      rethrow;
    }
  }

  Future<User?> iniciarSesion(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      print("Error en inicio de sesión: $e");
      rethrow;
    }
  }

  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }
}
