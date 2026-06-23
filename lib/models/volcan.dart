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
  final String? foto; // URL de una foto (de Wikipedia); puede ser null
  // Datos extra opcionales (se muestran solo si no son null).
  final String? mejorEpoca; // 📅 mejor época para visitar
  final String? entrada; // 🎟️ si cobran entrada
  final String? comida; // 🍲 comida típica de la zona
  final String? dato; // 💡 un dato curioso ("¿sabías que…?")

  const Volcan({
    required this.nombre,
    required this.lat,
    required this.lng,
    required this.alturaM,
    required this.departamento,
    required this.activo,
    required this.consejo,
    this.foto,
    this.mejorEpoca,
    this.entrada,
    this.comida,
    this.dato,
  });

  /// Coordenada que usa flutter_map.
  LatLng get punto => LatLng(lat, lng);
}
