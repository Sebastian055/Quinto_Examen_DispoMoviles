class CambioMoneda {
  final int? id;
  final DateTime fecha;
  final double valor;
  final String? nombreMoneda;

  CambioMoneda({
    this.id,
    required this.fecha,
    required this.valor,
    this.nombreMoneda,
  });

  factory CambioMoneda.fromJson(Map<String, dynamic> json) {
    return CambioMoneda(
      id: json['moneda']?['id'],
      nombreMoneda: json['moneda']?['nombre'],
      fecha: json['fecha'] != null
          ? DateTime.parse(json['fecha'])
          : DateTime.now(),
      valor: (json['valor'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreMoneda': nombreMoneda,
      'fecha': fecha.toIso8601String(),
      'valor': valor,
    };
  }

  @override
  String toString() {
    return '${fecha.day}/${fecha.month}/${fecha.year}: ${valor.toStringAsFixed(2)}';
  }
}
