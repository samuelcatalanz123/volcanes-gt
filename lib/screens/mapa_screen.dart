import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/volcanes.dart';
import '../services/ubicacion.dart';
import '../widgets/volcan_info.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final _mapController = MapController();
  // Centro aproximado de Guatemala. (LatLng no es const en latlong2 → final.)
  static final _centroGuate = LatLng(15.0, -90.3);
  // Límites del mapa: una caja que rodea Guatemala. Así el mapa NO se puede
  // arrastrar a otros países. (esquina sur-oeste y nor-este)
  static final _limitesGuate = LatLngBounds(
    LatLng(13.5, -92.5), // abajo-izquierda
    LatLng(18.0, -88.0), // arriba-derecha
  );
  LatLng? _yo; // ubicación del usuario (null si no hay)

  @override
  void initState() {
    super.initState();
    _ubicar();
  }

  Future<void> _ubicar() async {
    final pos = await obtenerUbicacion();
    if (pos != null && mounted) {
      setState(() => _yo = pos);
      _mapController.move(pos, 9);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🌋 Volcanes de Guatemala')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _centroGuate,
          initialZoom: 7.5,
          // El mapa se queda dentro de Guatemala y no se aleja ni acerca de más.
          minZoom: 7,
          maxZoom: 14,
          cameraConstraint: CameraConstraint.contain(bounds: _limitesGuate),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.samuel.volcanes_gt',
          ),
          MarkerLayer(
            markers: [
              // Un marcador por cada volcán: el ícono de fuego + su nombre debajo.
              for (final v in volcanes)
                Marker(
                  point: v.punto,
                  width: 110,
                  height: 56,
                  child: GestureDetector(
                    onTap: () => mostrarVolcanInfo(context, v),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_fire_department,
                            color: v.activo ? Colors.red : Colors.deepOrange,
                            size: 32),
                        // Etiqueta blanca con el nombre para ver dónde está.
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            v.nombre.replaceFirst('Volcán de ', ''),
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Marcador de la ubicación del usuario (si existe).
              if (_yo != null)
                Marker(
                  point: _yo!,
                  width: 24,
                  height: 24,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_yo != null) {
            _mapController.move(_yo!, 11);
          } else {
            _ubicar();
          }
        },
        tooltip: 'Centrar en mí',
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
