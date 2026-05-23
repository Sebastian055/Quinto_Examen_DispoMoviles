import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../configuracion/api_configuracion.dart';
import '../modelos/usuario.dart';

class AutenticacionServicio {
  // Almacenamiento seguro para el token encriptado
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Clave para guardar el token (es el NOMBRE, no el token)
  static const String _tokenKey = 'token_usuario';

  // Inicio de sesion con el servicio
  Future<Map<String, dynamic>> login(String usuario, String clave) async {
    try {
      // Construye la URL
      final url = ApiConfiguracion.getUrlLogin(usuario, clave);
      print('Url de login: $url');

      // Hacemos una peticion GET a la API
      final response = await http.get(Uri.parse(url));

      print('Codigo de respuesta:  ${response.statusCode}');
      print('Respuesta: ${response.body}');

      // Verificar la respuesta
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        final usuarioData = data['usuario'];
        final String? token = data['token'];

        if (token != null && token.isNotEmpty) {
          await _storage.write(key: _tokenKey, value: token);

          final usuarioObj = Usuario.fromJson(usuarioData);

          return {'success': true, 'token': token, 'usuario': usuarioObj};
        } else {
          return {
            'success': false,
            'error': 'Usuario o contraseñas incorrectos',
          };
        }
      } else if (response.statusCode == 401) {
        return {'success': false, 'error': 'Usuario o contraseñas incorrectos'};
      } else {
        return {
          'success': false,
          'error': 'error en el servidor (${response.statusCode})',
        };
      }
    } catch (e) {
      print('Error en login: $e');
      return {
        'success': false,
        'error': 'Error de conexión. ¿El servidor está corriendo?',
      };
    }
  }

  // Gestion del token
  Future<String?> obtenerToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> guardarToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> cerrarSesion() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<bool> estaAutenticado() async {
    final token = await obtenerToken();
    return token != null && token.isNotEmpty;
  }
}
