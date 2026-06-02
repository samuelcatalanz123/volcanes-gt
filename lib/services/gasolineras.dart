import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

/// Un punto que viene de OpenStreetMap: tiene nombre y ubicación.
/// Lo usamos tanto para gasolineras como para aldeas.
class PuntoOSM {
  final String nombre;
  final LatLng punto;
  const PuntoOSM(this.nombre, this.punto);
}

/// Un río: su nombre y la línea (lista de puntos) que lo dibuja en el mapa.
class Rio {
  final String nombre;
  final List<LatLng> puntos;
  const Rio(this.nombre, this.puntos);
}

/// Llama a la API Overpass de OpenStreetMap con una consulta y devuelve el
/// JSON ya decodificado. Reintenta porque el servidor a veces se satura.
Future<Map<String, dynamic>> _overpass(String query) async {
  final url = Uri.parse('https://overpass-api.de/api/interpreter');
  for (var intento = 0; intento < 3; intento++) {
    try {
      final res = await http
          .post(url, body: {'data': query})
          .timeout(const Duration(seconds: 70));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {
      // Falló este intento; probamos otra vez.
    }
  }
  throw Exception('Servidor ocupado, intenta de nuevo.');
}

/// Busca "nodos" (puntos) que cumplan un filtro dentro del área visible.
Future<List<PuntoOSM>> _buscarPuntos(LatLngBounds area, String filtro) async {
  final s = area.south, w = area.west, n = area.north, e = area.east;
  final data = await _overpass('[out:json][timeout:60];$filtro($s,$w,$n,$e);out;');
  final elementos = (data['elements'] as List).cast<Map<String, dynamic>>();
  return [
    for (final el in elementos)
      PuntoOSM(
        (el['tags']?['name'] as String?) ?? 'Sin nombre',
        LatLng((el['lat'] as num).toDouble(), (el['lon'] as num).toDouble()),
      ),
  ];
}

/// Gasolineras de la zona visible.
Future<List<PuntoOSM>> buscarGasolineras(LatLngBounds area) =>
    _buscarPuntos(area, 'node["amenity"="fuel"]');

/// Aldeas y caseríos de la zona visible.
Future<List<PuntoOSM>> buscarAldeas(LatLngBounds area) =>
    _buscarPuntos(area, 'node["place"~"village|hamlet"]');

/// Ríos de la zona visible. Cada río trae su línea de puntos para dibujarlo.
Future<List<Rio>> buscarRios(LatLngBounds area) async {
  final s = area.south, w = area.west, n = area.north, e = area.east;
  // "out geom" hace que cada río traiga su geometría (la lista de puntos).
  final data = await _overpass(
      '[out:json][timeout:60];way["waterway"="river"]($s,$w,$n,$e);out geom;');
  final elementos = (data['elements'] as List).cast<Map<String, dynamic>>();
  final rios = <Rio>[];
  for (final el in elementos) {
    final geom = el['geometry'] as List?;
    if (geom == null || geom.length < 2) continue;
    final puntos = [
      for (final p in geom)
        LatLng((p['lat'] as num).toDouble(), (p['lon'] as num).toDouble()),
    ];
    rios.add(Rio((el['tags']?['name'] as String?) ?? 'Río', puntos));
  }
  return rios;
}
