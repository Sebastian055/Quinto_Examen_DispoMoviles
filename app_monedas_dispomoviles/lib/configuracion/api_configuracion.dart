class ApiConfiguracion {
  static const String urlBase =
      'http://localhost:8080/api'; //Url base del servidor (de la API)

  //Endpoints especificos
  static const String loginEndpoint = '/usuarios/validar'; //Login (GET)
  static const String monedasListarEndpoint =
      '/monedas/listar'; //Listar monedas (GET)
  static const String monedasListarPorPeriodoEndpoint =
      '/monedas/listarporperiodo'; //Listar por periodo (POST)

  //Metodos para cosntruir los URLS completos
  static String getUrlLogin(String usuario, String clave) {
    return '$urlBase$loginEndpoint/$usuario/$clave';
  }

  static String getUrlListarMonedas() {
    return '$urlBase$monedasListarEndpoint';
  }

  static String getUrlListarPorPeriodo() {
    return '$urlBase$monedasListarPorPeriodoEndpoint';
  }
}
