// lib/vistas/pantalla_principal.dart
import 'package:flutter/material.dart';
import '../servicios/autenticacion_servicio.dart';
import '../servicios/moneda_servicio.dart';
import '../modelos/moneda.dart';
import '../modelos/cambio_moneda.dart';
import 'pantalla_login.dart';

class PantallaPrincipal extends StatefulWidget {
  final String token; // ← recibe el token desde login

  const PantallaPrincipal({super.key, required this.token});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final AutenticacionServicio _authServicio = AutenticacionServicio();
  final MonedaServicio _monedaServicio = MonedaServicio();

  // Controladores para los campos de fecha (texto editables)
  final TextEditingController _fechaInicioController = TextEditingController();
  final TextEditingController _fechaFinController = TextEditingController();

  List<Moneda> _monedas = [];
  List<CambioMoneda> _resultados = [];
  Moneda? _monedaSeleccionada;
  bool _cargandoMonedas = true;
  bool _consultando = false;

  @override
  void initState() {
    super.initState();
    _cargarMonedas(); // usa widget.token directamente, sin leer secure storage
  }

  @override
  void dispose() {
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    super.dispose();
  }

  Future<void> _cargarMonedas() async {
    setState(() => _cargandoMonedas = true);
    try {
      final monedas = await _monedaServicio.listarMonedas(widget.token);
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

    // Parsear las fechas desde los TextField
    DateTime? fechaInicio;
    DateTime? fechaFin;
    try {
      fechaInicio = DateTime.parse(_fechaInicioController.text.trim());
      fechaFin = DateTime.parse(_fechaFinController.text.trim());
    } catch (_) {
      _mostrarError('Formato de fecha inválido. Use YYYY-MM-DD');
      return;
    }

    if (fechaInicio.isAfter(fechaFin)) {
      _mostrarError('La fecha inicio debe ser anterior a la fecha fin');
      return;
    }

    setState(() => _consultando = true);
    try {
      final cambios = await _monedaServicio.listarCambiosPorPeriodo(
        token: widget.token,
        idMoneda: _monedaSeleccionada!.id,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
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
      // ← navega directamente a PantallaLogin, sin rutas nombradas
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PantallaLogin()),
      );
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
        title: const Text('Consulta de Cambios de Moneda'),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Dropdown de monedas ──────────────────────────────────────
            _cargandoMonedas
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<Moneda>(
                    value: _monedaSeleccionada,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: _monedas.map((moneda) {
                      return DropdownMenuItem(
                        value: moneda,
                        child: Text(moneda.moneda),
                      );
                    }).toList(),
                    onChanged: (moneda) {
                      setState(() => _monedaSeleccionada = moneda);
                    },
                  ),

            const SizedBox(height: 16),

            // ── Campo Desde ─────────────────────────────────────────────
            TextField(
              controller: _fechaInicioController,
              decoration: const InputDecoration(
                labelText: 'Desde (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),

            const SizedBox(height: 12),

            // ── Campo Hasta ─────────────────────────────────────────────
            TextField(
              controller: _fechaFinController,
              decoration: const InputDecoration(
                labelText: 'Hasta (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),

            const SizedBox(height: 16),

            // ── Botón Consultar ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _consultando ? null : _consultarCambios,
                child: _consultando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Consultar Cambios'),
              ),
            ),

            const SizedBox(height: 16),

            // ── Lista de resultados ─────────────────────────────────────
            Expanded(
              child: _resultados.isEmpty
                  ? const Center(child: Text('Sin resultados'))
                  : ListView.builder(
                      itemCount: _resultados.length,
                      itemBuilder: (context, index) {
                        final cambio = _resultados[index];
                        // Formato que pide el examen: "Fecha: YYYY-MM-DD" y "Valor: X"
                        final fechaStr =
                            '${cambio.fecha.year}-'
                            '${cambio.fecha.month.toString().padLeft(2, '0')}-'
                            '${cambio.fecha.day.toString().padLeft(2, '0')}';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Fecha: $fechaStr'),
                              Text('Valor: ${cambio.valor}'),
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
}
