import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Recuerda si el usuario eligió español o inglés (lo guarda en el dispositivo).
class Idioma {
  Idioma._();

  static const _clave = 'idioma_ingles';
  static SharedPreferences? _prefs;

  /// true = inglés. Escucha esto para redibujar la app al cambiar de idioma.
  static final ValueNotifier<bool> ingles = ValueNotifier<bool>(false);

  static Future<void> cargar() async {
    _prefs = await SharedPreferences.getInstance();
    ingles.value = _prefs!.getBool(_clave) ?? false;
  }

  static bool get esIngles => ingles.value;

  static Future<void> alternar() async {
    ingles.value = !ingles.value;
    await _prefs?.setBool(_clave, ingles.value);
  }
}

/// Devuelve el texto en español [es] o en inglés [en] según el idioma elegido.
/// Ejemplo: tr('Buscar', 'Search').
String tr(String es, String en) => Idioma.esIngles ? en : es;
