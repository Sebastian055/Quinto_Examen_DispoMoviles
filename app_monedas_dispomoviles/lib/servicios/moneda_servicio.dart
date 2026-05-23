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
      print('Body monedas: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Total monedas parseadas: ${data.length}');
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

      final desdeStr = _formatearFecha(fechaInicio);
      final hastaStr = _formatearFecha(fechaFin);

      final Map<String, dynamic> body = {
        'idMoneda': idMoneda,
        'desde': desdeStr,
        'hasta': hastaStr,
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
        final dynamic data = json.decode(response.body);

        print('Tipo de respuesta: ${data.runtimeType}');

        if (data is List) {
          if (data.isEmpty) {
            print('No hay datos en el período seleccionado');
            return [];
          }
          print('Se encontraron ${data.length} registros (como lista)');
          return data.map((item) => CambioMoneda.fromJson(item)).toList();
        } else if (data is Map<String, dynamic>) {
          if (data['fecha'] != null || data['valor'] != null) {
            print('Se encontró 1 registro (como objeto)');
            return [CambioMoneda.fromJson(data)];
          }
          print('El objeto no contiene datos válidos');
          return [];
        } else {
          print('Formato de respuesta no reconocido: ${data.runtimeType}');
          return [];
        }
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

  String _formatearFecha(DateTime fecha) {
    return '${fecha.year}-${_agregarCero(fecha.month)}-${_agregarCero(fecha.day)}';
  }

  String _agregarCero(int numero) {
    return numero.toString().padLeft(2, '0');
  }
}
