//Clase usuario
class Usuario {
  final int? id;
  final String usuario;
  final String nombre;
  final String? clave;
  final String? roles;

  //Constructor de usuario
  Usuario({
    this.id,
    required this.usuario,
    required this.nombre,
    this.clave,
    this.roles,
  });

  //Convierte el JSON que llega de la API ah el objeto Usuario
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      usuario: json['usuario'] ?? '',
      nombre: json['nombre'] ?? '',
      clave: json['clave'],
      roles: json['roles'],
    );
  }

  //Convierte el objeto usuario a JSON (para enviar a la API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario': usuario,
      'nombre': nombre,
      'clave': clave,
      'roles': roles,
    };
  }
}
