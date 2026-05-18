// lib/servicios/moneda_servicio.dart
// Propósito: Consumir los endpoints de monedas de la API

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configuracion/api_configuracion.dart';
import '../modelos/moneda.dart';
import '../modelos/cambio_moneda.dart';

class MonedaServicio {
  /// Requiere el token de autenticación
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

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Moneda.fromJson(json)).toList();
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

  /// Obtiene los cambios de una moneda en un rango de fechas
  /// Requiere el token de autenticación
  Future<List<CambioMoneda>> listarCambiosPorPeriodo({
    required String token,
    required int idMoneda,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    try {
      final url = ApiConfiguracion.getUrlListarPorPeriodo();
      print('URL listar por período: $url');

      // Formatear fechas para la API (YYYY-MM-DD)
      final fechaInicioStr = _formatearFecha(fechaInicio);
      final fechaFinStr = _formatearFecha(fechaFin);

      // Construir el cuerpo de la petición POST
      final Map<String, dynamic> body = {
        'idMoneda': idMoneda,
        'fechaInicio': fechaInicioStr,
        'fechaFin': fechaFinStr,
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
        return data.map((json) => CambioMoneda.fromJson(json)).toList();
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

  // MÉTODO AUXILIAR PRIVADO

  /// Convierte DateTime a formato YYYY-MM-DD
  String _formatearFecha(DateTime fecha) {
    return '${fecha.year}-${_agregarCero(fecha.month)}-${_agregarCero(fecha.day)}';
  }

  /// Agrega un cero adelante si el número es menor a 10
  String _agregarCero(int numero) {
    return numero.toString().padLeft(2, '0');
  }
}
