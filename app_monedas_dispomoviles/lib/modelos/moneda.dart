//Clase moneda
class Moneda {
  final int id;
  final String sigla;
  final String moneda;
  final String? simbolo;
  final String? emisor;

  //Constructor moneda
  Moneda({
    required this.id,
    required this.sigla,
    required this.moneda,
    this.simbolo,
    this.emisor,
  });

  //Metodo para convertir el .JSON en objeto moneda
  factory Moneda.fromJson(Map<String, dynamic> json) {
    return Moneda(
      id: json['id'] ?? 0,
      sigla: json['sigla'] ?? '',
      moneda: json['nombre'] ?? '',
      simbolo: json['simbolo'] ?? '',
      emisor: json['emisor'] ?? '',
    );
  }

  //Convierte el objeto moneda a JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'sigla': sigla, 'moneda': moneda, 'emisor': emisor};
  }

  //Metodo para mostrar el dropdown
  @override
  String toString() {
    return '$sigla - $moneda';
  }
}
