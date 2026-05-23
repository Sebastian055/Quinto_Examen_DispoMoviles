import 'package:flutter/material.dart';
import '../servicios/autenticacion_servicio.dart';
import '../servicios/moneda_servicio.dart';
import '../modelos/moneda.dart';
import '../modelos/cambio_moneda.dart';
import 'pantalla_login.dart';

class PantallaPrincipal extends StatefulWidget {
  final String token;

  const PantallaPrincipal({super.key, required this.token});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final AutenticacionServicio _authServicio = AutenticacionServicio();
  final MonedaServicio _monedaServicio = MonedaServicio();

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
    _cargarMonedas();
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
      } else {
        _mostrarInfo('Se encontraron ${cambios.length} registros');
      }
    } catch (e) {
      setState(() => _consultando = false);
      _mostrarError(e.toString());
    }
  }

  Future<void> _cerrarSesion() async {
    await _authServicio.cerrarSesion();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PantallaLogin()),
      );
    }
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _mostrarInfo(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.blue[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Cambio de Monedas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _cargandoMonedas
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.green),
                      ),
                    )
                  : DropdownButtonFormField<Moneda>(
                      value: _monedaSeleccionada,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Seleccionar moneda',
                        prefixIcon: const Icon(
                          Icons.currency_exchange,
                          color: Colors.green,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      items: _monedas.map((moneda) {
                        return DropdownMenuItem(
                          value: moneda,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.attach_money,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                moneda.moneda,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (moneda) {
                        setState(() => _monedaSeleccionada = moneda);
                      },
                    ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _fechaInicioController,
                decoration: InputDecoration(
                  labelText: 'Fecha desde',
                  hintText: 'YYYY-MM-DD',
                  prefixIcon: const Icon(
                    Icons.calendar_today,
                    color: Colors.green,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                keyboardType: TextInputType.datetime,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _fechaFinController,
                decoration: InputDecoration(
                  labelText: 'Fecha hasta',
                  hintText: 'YYYY-MM-DD',
                  prefixIcon: const Icon(
                    Icons.calendar_today,
                    color: Colors.green,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                keyboardType: TextInputType.datetime,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _consultando ? null : _consultarCambios,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _consultando
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search),
                          SizedBox(width: 8),
                          Text(
                            'Consultar Cambios',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _resultados.isEmpty
                  ? Container(
                      margin: const EdgeInsets.only(top: 40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.bar_chart,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Sin resultados',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Seleccione una moneda y fechas para consultar',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _resultados.length,
                      itemBuilder: (context, index) {
                        final cambio = _resultados[index];
                        final fechaStr =
                            '${cambio.fecha.day}/${cambio.fecha.month}/${cambio.fecha.year}';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              'Fecha: ${fechaStr}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              'Valor: ${cambio.valor.toStringAsFixed(4)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: cambio.valor > 0
                                ? const Icon(
                                    Icons.trending_up,
                                    color: Colors.green,
                                  )
                                : const Icon(
                                    Icons.trending_down,
                                    color: Colors.red,
                                  ),
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
