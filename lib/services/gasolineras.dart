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

/// Pregunta genérica a OpenStreetMap (API Overpass) por nodos que cumplan un
/// filtro, dentro del área visible. [filtro] es la parte de la consulta
/// Overpass, por ejemplo: node["amenity"="fuel"]
/// Lanza una excepción si el servidor falla varias veces.
Future<List<PuntoOSM>> _consultarOverpass(
    LatLngBounds area, String filtro) async {
  // Overpass usa el orden: sur, oeste, norte, este.
  final s = area.south, w = area.west, n = area.north, e = area.east;
  final query = '[out:json][timeout:60];$filtro($s,$w,$n,$e);out;';
  final url = Uri.parse('https://overpass-api.de/api/interpreter');

  // El servidor público a veces se satura: reintentamos un par de veces.
  for (var intento = 0; intento < 3; intento++) {
    try {
      final res = await http
          .post(url, body: {'data': query})
          .timeout(const Duration(seconds: 70));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final elementos =
            (data['elements'] as List).cast<Map<String, dynamic>>();
        return [
          for (final el in elementos)
            PuntoOSM(
              (el['tags']?['name'] as String?) ?? 'Sin nombre',
              LatLng((el['lat'] as num).toDouble(),
                  (el['lon'] as num).toDouble()),
            ),
        ];
      }
    } catch (_) {
      // Falló este intento; probamos otra vez.
    }
  }
  throw Exception('Servidor ocupado, intenta de nuevo.');
}

/// Gasolineras de la zona visible.
Future<List<PuntoOSM>> buscarGasolineras(LatLngBounds area) =>
    _consultarOverpass(area, 'node["amenity"="fuel"]');

/// Aldeas y caseríos de la zona visible.
Future<List<PuntoOSM>> buscarAldeas(LatLngBounds area) =>
    _consultarOverpass(area, 'node["place"~"village|hamlet"]');
