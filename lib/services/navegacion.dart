import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'idioma.dart';

/// Un paso de la ruta: dónde es la maniobra y qué hay que hacer.
class PasoRuta {
  final LatLng punto;
  final String instruccion;
  final double distanciaM; // largo de este tramo en metros

  const PasoRuta({
    required this.punto,
    required this.instruccion,
    required this.distanciaM,
  });
}

/// Una ruta completa: la línea para dibujar y la lista de instrucciones.
class Ruta {
  final List<LatLng> puntos; // para dibujar la línea en el mapa
  final List<PasoRuta> pasos; // instrucciones paso a paso
  final double distanciaKm;
  final int duracionMin;

  const Ruta({
    required this.puntos,
    required this.pasos,
    required this.distanciaKm,
    required this.duracionMin,
  });
}

/// Calcula la ruta en carro entre dos puntos usando OSRM (gratis, sin clave).
/// Devuelve null si no se pudo calcular.
Future<Ruta?> obtenerRuta(LatLng origen, LatLng destino) async {
  final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${origen.longitude},${origen.latitude};'
      '${destino.longitude},${destino.latitude}'
      '?overview=full&geometries=geojson&steps=true');
  try {
    final resp = await http.get(url).timeout(const Duration(seconds: 15));
    if (resp.statusCode != 200) return null;
    final data = jsonDecode(resp.body);
    if (data['code'] != 'Ok') return null;

    final ruta = data['routes'][0];

    // Línea de la ruta (la geometría viene como [lng, lat]).
    final coords = ruta['geometry']['coordinates'] as List;
    final puntos = coords
        .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
        .toList();

    // Instrucciones paso a paso.
    final pasos = <PasoRuta>[];
    for (final step in ruta['legs'][0]['steps'] as List) {
      final m = step['maneuver'];
      final loc = m['location'] as List;
      pasos.add(PasoRuta(
        punto: LatLng((loc[1] as num).toDouble(), (loc[0] as num).toDouble()),
        instruccion: _instruccion(
            m['type'] as String, m['modifier'] as String?, step['name'] ?? ''),
        distanciaM: (step['distance'] as num).toDouble(),
      ));
    }

    return Ruta(
      puntos: puntos,
      pasos: pasos,
      distanciaKm: (ruta['distance'] as num) / 1000,
      duracionMin: ((ruta['duration'] as num) / 60).round(),
    );
  } catch (_) {
    return null;
  }
}

/// Convierte la maniobra de OSRM (en inglés) a una instrucción en español.
String _instruccion(String tipo, String? mod, String calle) {
  final porCalle =
      calle.toString().isNotEmpty ? tr(' por $calle', ' on $calle') : '';
  switch (tipo) {
    case 'depart':
      return tr('Empieza el viaje$porCalle', 'Start the trip$porCalle');
    case 'arrive':
      return tr('¡Has llegado a tu destino!', 'You have arrived!');
    case 'turn':
      return tr('Gira ${_lado(mod)}$porCalle', 'Turn ${_lado(mod)}$porCalle');
    case 'end of road':
      return tr('Al final de la calle, gira ${_lado(mod)}$porCalle',
          'At the end of the road, turn ${_lado(mod)}$porCalle');
    case 'new name':
    case 'continue':
      return tr('Sigue derecho$porCalle', 'Continue straight$porCalle');
    case 'merge':
      return tr(
          'Incorpórate ${_lado(mod)}$porCalle', 'Merge ${_lado(mod)}$porCalle');
    case 'on ramp':
      return tr('Toma la rampa ${_lado(mod)}', 'Take the ramp ${_lado(mod)}');
    case 'off ramp':
      return tr('Toma la salida ${_lado(mod)}', 'Take the exit ${_lado(mod)}');
    case 'fork':
      return tr('En la bifurcación, mantente ${_lado(mod)}',
          'At the fork, keep ${_lado(mod)}');
    case 'roundabout':
    case 'rotary':
      return tr('Entra a la rotonda$porCalle', 'Enter the roundabout$porCalle');
    default:
      return calle.toString().isNotEmpty
          ? tr('Sigue$porCalle', 'Continue$porCalle')
          : tr('Sigue derecho', 'Continue straight');
  }
}

/// El lado de la maniobra (left/right…) en el idioma elegido.
String _lado(String? mod) {
  switch (mod) {
    case 'left':
      return tr('a la izquierda', 'left');
    case 'right':
      return tr('a la derecha', 'right');
    case 'slight left':
      return tr('ligeramente a la izquierda', 'slightly left');
    case 'slight right':
      return tr('ligeramente a la derecha', 'slightly right');
    case 'sharp left':
      return tr('cerrado a la izquierda', 'sharp left');
    case 'sharp right':
      return tr('cerrado a la derecha', 'sharp right');
    case 'uturn':
      return tr('en U', 'a U-turn');
    case 'straight':
      return tr('derecho', 'straight');
    default:
      return '';
  }
}
