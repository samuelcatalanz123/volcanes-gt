import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

/// Una gasolinera con su nombre y ubicación.
class Gasolinera {
  final String nombre;
  final LatLng punto;
  const Gasolinera(this.nombre, this.punto);
}

/// Pide a OpenStreetMap (API Overpass) las gasolineras dentro del área visible.
/// Devuelve la lista. Lanza una excepción si el servidor falla varias veces.
Future<List<Gasolinera>> buscarGasolineras(LatLngBounds area) async {
  // Overpass usa el orden: sur, oeste, norte, este.
  final s = area.south, w = area.west, n = area.north, e = area.east;
  final query =
      '[out:json][timeout:60];node["amenity"="fuel"]($s,$w,$n,$e);out;';
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
            Gasolinera(
              (el['tags']?['name'] as String?) ?? 'Gasolinera',
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
