// lib/vistas/pantalla_login.dart
import 'package:flutter/material.dart';
import '../servicios/autenticacion_servicio.dart';
import 'pantalla_principal.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _claveController = TextEditingController();
  final AutenticacionServicio _authServicio = AutenticacionServicio();
  bool _cargando = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            const Text('Usuario:'),
            const SizedBox(height: 8),
            TextField(controller: _usuarioController),
            const SizedBox(height: 20),
            const Text('Clave:'),
            const SizedBox(height: 8),
            TextField(controller: _claveController, obscureText: true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _iniciarSesion,
                      child: const Text('Iniciar sesión'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _iniciarSesion() async {
    if (_usuarioController.text.isEmpty || _claveController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete todos los campos')),
      );
      return;
    }

    setState(() => _cargando = true);

    final resultado = await _authServicio.login(
      _usuarioController.text,
      _claveController.text,
    );

    setState(() => _cargando = false);

    if (resultado['success'] == true) {
      final String token = resultado['token']; // ← tomamos el token aquí
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            // ↓ lo pasamos directo, sin depender de secure storage en la siguiente pantalla
            builder: (context) => PantallaPrincipal(token: token),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado['error'] ?? 'Usuario o Clave incorrectos'),
          ),
        );
      }
    }
  }
}
