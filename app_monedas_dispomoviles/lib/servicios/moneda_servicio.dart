// lib/servicios/moneda_servicio.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configuracion/api_configuracion.dart';
import '../modelos/moneda.dart';
import '../modelos/cambio_moneda.dart';

class MonedaServicio {
  Future<List<Moneda>> listarMonedas(String token) async {
    try {
      final url = ApiConfiguracion.getUrlListarMonedas();
      print('URL listar monedas: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Código respuesta monedas: ${response.statusCode}');
      print('Body monedas: ${response.body}'); // ← AGREGADO

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Total monedas parseadas: ${data.length}'); // ← AGREGADO
        return data.map((item) => Moneda.fromJson(item)).toList();
      } else if (response.statusCode == 403) {
        throw Exception('Sesión expirada. Inicie sesión nuevamente.');
      } else {
        throw Exception('Error al cargar las monedas (${response.statusCode})');
      }
    } catch (e) {
      print('Error en listarMonedas: $e');
      throw Exception('Error de conexión al listar monedas');
    }
  }

  Future<List<CambioMoneda>> listarCambiosPorPeriodo({
    required String token,
    required int idMoneda,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    try {
      final url = ApiConfiguracion.getUrlListarPorPeriodo();
      print('URL listar por período: $url');

      // ← CORREGIDO: solo YYYY-MM-DD, sin la parte de tiempo
      final desdeStr = _formatearFecha(fechaInicio);
      final hastaStr = _formatearFecha(fechaFin);

      final Map<String, dynamic> body = {
        'idMoneda': idMoneda,
        'desde': fechaInicio.toIso8601String(),
        'hasta': fechaFin.toIso8601String(),
      };

      print('Cuerpo de la petición: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      print('Código respuesta cambios: ${response.statusCode}');
      print('Respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => CambioMoneda.fromJson(item)).toList();
      } else if (response.statusCode == 403) {
        throw Exception('Sesión expirada. Inicie sesión nuevamente.');
      } else {
        throw Exception(
          'Error al consultar los cambios (${response.statusCode})',
        );
      }
    } catch (e) {
      print('Error en listarCambiosPorPeriodo: $e');
      throw Exception('Error de conexión al consultar cambios');
    }
  }

  // Formato YYYY-MM-DD que espera la API
  String _formatearFecha(DateTime fecha) {
    return '${fecha.year}-${_agregarCero(fecha.month)}-${_agregarCero(fecha.day)}';
  }

  String _agregarCero(int numero) {
    return numero.toString().padLeft(2, '0');
  }
}
