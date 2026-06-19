import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

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
    final resp = await http.get(url);
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
  final porCalle = calle.toString().isNotEmpty ? ' por $calle' : '';
  switch (tipo) {
    case 'depart':
      return 'Empieza el viaje$porCalle';
    case 'arrive':
      return '¡Has llegado a tu destino!';
    case 'turn':
      return 'Gira ${_lado(mod)}$porCalle';
    case 'end of road':
      return 'Al final de la calle, gira ${_lado(mod)}$porCalle';
    case 'new name':
    case 'continue':
      return 'Sigue derecho$porCalle';
    case 'merge':
      return 'Incorpórate ${_lado(mod)}$porCalle';
    case 'on ramp':
      return 'Toma la rampa ${_lado(mod)}';
    case 'off ramp':
      return 'Toma la salida ${_lado(mod)}';
    case 'fork':
      return 'En la bifurcación, mantente ${_lado(mod)}';
    case 'roundabout':
    case 'rotary':
      return 'Entra a la rotonda$porCalle';
    default:
      return calle.toString().isNotEmpty ? 'Sigue$porCalle' : 'Sigue derecho';
  }
}

/// Traduce el lado de la maniobra (left/right…) a español.
String _lado(String? mod) {
  switch (mod) {
    case 'left':
      return 'a la izquierda';
    case 'right':
      return 'a la derecha';
    case 'slight left':
      return 'ligeramente a la izquierda';
    case 'slight right':
      return 'ligeramente a la derecha';
    case 'sharp left':
      return 'cerrado a la izquierda';
    case 'sharp right':
      return 'cerrado a la derecha';
    case 'uturn':
      return 'en U';
    case 'straight':
      return 'derecho';
    default:
      return '';
  }
}
