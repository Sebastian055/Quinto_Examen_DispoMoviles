class CambioMoneda {
  final int id;
  final int idMoneda;
  final DateTime fecha;
  final double valor;

  CambioMoneda({
    required this.id,
    required this.idMoneda,
    required this.fecha,
    required this.valor,
  });

  //Convierte el .JSON que llega en objeto CambioMoneda
  factory CambioMoneda.fromJson(Map<String, dynamic> json) {
    return CambioMoneda(
      id: json['id'] ?? 0,
      idMoneda: json['idMoneda'] ?? 0,
      fecha: json['fecha'] != null
          ? DateTime.parse(json['fecha'])
          : DateTime.now(),
      valor: (json['valor'] ?? 0).toDouble(),
    );
  }

  //Convierte el objeto CambioMoneda a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idMoneda': idMoneda,
      'fecha': fecha.toIso8601String(),
      'valor': valor,
    };
  }

  //Metodo auxiliar para poder mostrar el cambio de moneda en la lista
  @override
  String toString() {
    return '${fecha.day}/${fecha.month}/${fecha.year}: ${valor.toStringAsFixed(2)}';
  }
}
