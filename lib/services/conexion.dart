import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Sabe si el dispositivo tiene conexión a internet (wifi o datos) y avisa
/// cuando cambia. Escucha [hayInternet] para mostrar/ocultar el aviso.
class Conexion {
  Conexion._();

  static final ValueNotifier<bool> hayInternet = ValueNotifier<bool>(true);

  /// Empieza a vigilar la conexión. Llamar una vez al arrancar.
  static Future<void> iniciar() async {
    final c = Connectivity();
    _actualizar(await c.checkConnectivity());
    c.onConnectivityChanged.listen(_actualizar);
  }

  static void _actualizar(List<ConnectivityResult> resultados) {
    // Sin conexión = la lista está vacía o solo trae "none".
    final sinConexion = resultados.isEmpty ||
        resultados.every((r) => r == ConnectivityResult.none);
    hayInternet.value = !sinConexion;
  }
}
