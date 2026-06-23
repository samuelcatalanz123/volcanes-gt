import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Recuerda si el usuario eligió tema claro u oscuro (lo guarda en el
/// dispositivo). Por defecto sigue el tema del sistema.
class Tema {
  Tema._();

  static const _clave = 'tema_oscuro';
  static SharedPreferences? _prefs;

  /// El modo actual. Escucha esto en el MaterialApp para redibujar la app.
  static final ValueNotifier<ThemeMode> modo =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  /// Carga la preferencia guardada. Llamar una vez al arrancar.
  static Future<void> cargar() async {
    _prefs = await SharedPreferences.getInstance();
    final guardado = _prefs!.getBool(_clave);
    modo.value = guardado == null
        ? ThemeMode.system
        : (guardado ? ThemeMode.dark : ThemeMode.light);
  }

  static bool get esOscuro => modo.value == ThemeMode.dark;

  /// Cambia entre claro y oscuro y lo guarda.
  static Future<void> alternar() async {
    final oscuro = modo.value != ThemeMode.dark;
    modo.value = oscuro ? ThemeMode.dark : ThemeMode.light;
    await _prefs?.setBool(_clave, oscuro);
  }
}
