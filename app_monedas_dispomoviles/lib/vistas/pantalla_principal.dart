// lib/vistas/pantalla_principal.dart
// Propósito: Pantalla principal con consulta de monedas (estilo limpio)

import 'package:flutter/material.dart';
import '../servicios/autenticacion_servicio.dart';
import '../servicios/moneda_servicio.dart';
import '../modelos/moneda.dart';
import '../modelos/cambio_moneda.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final AutenticacionServicio _authServicio = AutenticacionServicio();
  final MonedaServicio _monedaServicio = MonedaServicio();

  List<Moneda> _monedas = [];
  List<CambioMoneda> _resultados = [];
  Moneda? _monedaSeleccionada;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  bool _cargandoMonedas = true;
  bool _consultando = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  Future<void> _cargarDatosIniciales() async {
    _token = await _authServicio.obtenerToken();
    if (_token == null || _token!.isEmpty) {
      _cerrarSesion();
      return;
    }
    await _cargarMonedas();
  }

  Future<void> _cargarMonedas() async {
    setState(() => _cargandoMonedas = true);
    try {
      final monedas = await _monedaServicio.listarMonedas(_token!);
      setState(() {
        _monedas = monedas;
        _cargandoMonedas = false;
        if (_monedas.isNotEmpty) _monedaSeleccionada = _monedas.first;
      });
    } catch (e) {
      setState(() => _cargandoMonedas = false);
      _mostrarError(e.toString());
    }
  }

  Future<void> _consultarCambios() async {
    if (_monedaSeleccionada == null) {
      _mostrarError('Seleccione una moneda');
      return;
    }
    if (_fechaInicio == null || _fechaFin == null) {
      _mostrarError('Seleccione un rango de fechas');
      return;
    }
    if (_fechaInicio!.isAfter(_fechaFin!)) {
      _mostrarError('La fecha inicio debe ser anterior a la fecha fin');
      return;
    }

    setState(() => _consultando = true);
    try {
      final cambios = await _monedaServicio.listarCambiosPorPeriodo(
        token: _token!,
        idMoneda: _monedaSeleccionada!.id,
        fechaInicio: _fechaInicio!,
        fechaFin: _fechaFin!,
      );
      setState(() {
        _resultados = cambios;
        _consultando = false;
      });
      if (cambios.isEmpty) {
        _mostrarInfo('No hay datos en el período seleccionado');
      }
    } catch (e) {
      setState(() => _consultando = false);
      _mostrarError(e.toString());
    }
  }

  Future<void> _cerrarSesion() async {
    await _authServicio.cerrarSesion();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  void _mostrarInfo(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.blue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Consulta de Cambios de Moneda',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _cerrarSesion,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown de monedas
            const Text(
              'Moneda',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            _cargandoMonedas
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Moneda>(
                        value: _monedaSeleccionada,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        items: _monedas.map((moneda) {
                          return DropdownMenuItem(
                            value: moneda,
                            child: Text(
                              moneda.moneda,
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
                        onChanged: (moneda) {
                          setState(() => _monedaSeleccionada = moneda);
                        },
                      ),
                    ),
                  ),
            const SizedBox(height: 24),

            // Fechas
            Row(
              children: [
                Expanded(child: _buildCampoFecha('Desde', _fechaInicio, true)),
                const SizedBox(width: 16),
                Expanded(child: _buildCampoFecha('Hasta', _fechaFin, false)),
              ],
            ),
            const SizedBox(height: 32),

            // Botón Consultar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _consultando ? null : _consultarCambios,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _consultando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Consultar Cambios',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Resultados
            const Text(
              'Resultados',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _resultados.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.show_chart,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay datos para mostrar',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: _resultados.length,
                      separatorBuilder: (_, __) => const Divider(height: 0),
                      itemBuilder: (context, index) {
                        final cambio = _resultados[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatearFecha(cambio.fecha),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                'Valor: ${cambio.valor.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampoFecha(String label, DateTime? fecha, bool esInicio) {
    return InkWell(
      onTap: () async {
        final nuevaFecha = await showDatePicker(
          context: context,
          initialDate: fecha ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          locale: const Locale('es', 'ES'),
        );
        if (nuevaFecha != null) {
          setState(() {
            if (esInicio) {
              _fechaInicio = nuevaFecha;
            } else {
              _fechaFin = nuevaFecha;
            }
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              fecha != null
                  ? '${_agregarCero(fecha.day)}/${_agregarCero(fecha.month)}/${fecha.year}'
                  : 'YYYY-MM-DD',
              style: TextStyle(
                fontSize: 14,
                color: fecha != null ? Colors.black87 : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${_agregarCero(fecha.day)}/${_agregarCero(fecha.month)}/${fecha.year}';
  }

  String _agregarCero(int numero) {
    return numero.toString().padLeft(2, '0');
  }
}
