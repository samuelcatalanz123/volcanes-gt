import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Devuelve la ubicación del usuario, o null si no se puede (permiso negado,
/// GPS apagado, etc.). La app debe seguir funcionando si devuelve null.
Future<LatLng?> obtenerUbicacion() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return null;
    }
    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }
    if (permiso == LocationPermission.denied ||
        permiso == LocationPermission.deniedForever) {
      return null;
    }
    final pos = await Geolocator.getCurrentPosition();
    return LatLng(pos.latitude, pos.longitude);
  } catch (_) {
    return null;
  }
}
