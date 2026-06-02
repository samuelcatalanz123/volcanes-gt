import 'package:latlong2/latlong.dart';

/// Tipos de lugar turístico que mostramos en el mapa (además de los volcanes).
enum TipoLugar { lago, playa, montana }

/// Un lugar turístico de Guatemala: un lago, una playa o una montaña.
class Lugar {
  final String nombre;
  final double lat;
  final double lng;
  final TipoLugar tipo;
  final String departamento;
  final String descripcion;
  final String? foto; // URL de una foto (de Wikipedia); puede ser null

  const Lugar({
    required this.nombre,
    required this.lat,
    required this.lng,
    required this.tipo,
    required this.departamento,
    required this.descripcion,
    this.foto,
  });

  LatLng get punto => LatLng(lat, lng);
}
