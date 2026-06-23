import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda los lugares/volcanes favoritos del usuario (por su nombre) y los
/// recuerda aunque cierre la app (usa el almacenamiento del dispositivo).
///
/// Es un servicio global con un [notifier] para que la estrella ⭐ se actualice
/// sola en cualquier parte de la app cuando cambian los favoritos.
class Favoritos {
  Favoritos._();

  static const _clave = 'favoritos';
  static SharedPreferences? _prefs;

  /// El conjunto de nombres favoritos. Escucha esto para redibujar.
  static final ValueNotifier<Set<String>> notifier =
      ValueNotifier<Set<String>>(<String>{});

  /// Carga los favoritos guardados. Llamar una vez al arrancar la app.
  static Future<void> cargar() async {
    _prefs = await SharedPreferences.getInstance();
    notifier.value = (_prefs!.getStringList(_clave) ?? <String>[]).toSet();
  }

  static bool esFavorito(String nombre) => notifier.value.contains(nombre);

  /// Marca o desmarca un favorito y lo guarda.
  static Future<void> alternar(String nombre) async {
    final nuevos = {...notifier.value};
    if (!nuevos.add(nombre)) nuevos.remove(nombre); // ya estaba → quitar
    notifier.value = nuevos;
    await _prefs?.setStringList(_clave, nuevos.toList());
  }
}

/// Botón de estrella ⭐ que marca/desmarca un favorito y se actualiza solo
/// (en todas partes a la vez) cuando cambian los favoritos.
class BotonFavorito extends StatelessWidget {
  final String nombre;
  final double size;
  const BotonFavorito({super.key, required this.nombre, this.size = 26});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: Favoritos.notifier,
      builder: (context, favoritos, _) {
        final esFav = favoritos.contains(nombre);
        return IconButton(
          tooltip: esFav ? 'Quitar de favoritos' : 'Agregar a favoritos',
          icon: Icon(esFav ? Icons.star : Icons.star_border,
              color: esFav ? Colors.amber : null, size: size),
          onPressed: () => Favoritos.alternar(nombre),
        );
      },
    );
  }
}
