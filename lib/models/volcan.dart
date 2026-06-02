import 'package:latlong2/latlong.dart';

/// Un volcán de Guatemala.
class Volcan {
  final String nombre;
  final double lat;
  final double lng;
  final int alturaM;
  final String departamento;
  final bool activo;
  final String consejo;

  const Volcan({
    required this.nombre,
    required this.lat,
    required this.lng,
    required this.alturaM,
    required this.departamento,
    required this.activo,
    required this.consejo,
  });

  /// Coordenada que usa flutter_map.
  LatLng get punto => LatLng(lat, lng);
}
