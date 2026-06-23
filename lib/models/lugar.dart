import 'package:latlong2/latlong.dart';

/// Tipos de lugar turístico que mostramos en el mapa (además de los volcanes).
enum TipoLugar { lago, playa, montana, ciudad, sitio }

/// Un lugar turístico de Guatemala: un lago, una playa, una montaña o una ciudad.
class Lugar {
  final String nombre;
  final double lat;
  final double lng;
  final TipoLugar tipo;
  final String departamento;
  final String descripcion;
  final String? foto; // URL de una foto (de Wikipedia); puede ser null
  // Galería opcional: si tiene varias fotos, se muestran deslizables.
  final List<String>? fotos;
  // Datos extra opcionales (se muestran solo si no son null).
  final String? mejorEpoca; // 📅 mejor época para visitar
  final String? entrada; // 🎟️ si cobran entrada
  final String? comida; // 🍲 comida típica de la zona
  final String? dato; // 💡 un dato curioso ("¿sabías que…?")

  const Lugar({
    required this.nombre,
    required this.lat,
    required this.lng,
    required this.tipo,
    required this.departamento,
    required this.descripcion,
    this.foto,
    this.fotos,
    this.mejorEpoca,
    this.entrada,
    this.comida,
    this.dato,
  });

  LatLng get punto => LatLng(lat, lng);
}
