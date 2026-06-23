import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../services/navegacion.dart';
import '../services/ubicacion.dart';
import '../services/idioma.dart';

/// Pantalla de navegación paso a paso: dibuja la ruta, sigue tu GPS y te va
/// diciendo por voz qué hacer ("gira a la derecha, sigue derecho").
class NavegacionScreen extends StatefulWidget {
  final LatLng destino;
  final String nombreDestino;

  const NavegacionScreen({
    super.key,
    required this.destino,
    required this.nombreDestino,
  });

  @override
  State<NavegacionScreen> createState() => _NavegacionScreenState();
}

class _NavegacionScreenState extends State<NavegacionScreen> {
  final MapController _map = MapController();
  final FlutterTts _tts = FlutterTts();
  StreamSubscription<Position>? _gps;

  Ruta? _ruta;
  LatLng? _yo;
  int _paso = 0; // próxima maniobra por anunciar
  String _estado = '';
  String _origenNombre = '';
  bool _cargando = true;
  bool _vozLista = false; // ¿el usuario ya tocó 🔊 para activar la voz?

  // Puntos de partida fijos que el usuario puede elegir (además del GPS).
  static const Map<String, LatLng> _ciudades = {
    'Guazacapán': LatLng(14.0782, -90.4186),
    'Ciudad de Guatemala': LatLng(14.6349, -90.5069),
    'Quetzaltenango (Xela)': LatLng(14.8347, -91.5180),
    'Escuintla': LatLng(14.3050, -90.7850),
  };

  @override
  void initState() {
    super.initState();
    _tts.setLanguage(Idioma.esIngles ? 'en-US' : 'es-ES');
    _tts.setSpeechRate(0.5);
    _estado = tr('Calculando la ruta…', 'Calculating route…');
    _iniciar();
  }

  // Arranca usando el GPS; si no se puede, usa Guazacapán como respaldo.
  Future<void> _iniciar() async {
    final gps = await obtenerUbicacion();
    if (gps != null) {
      _calcularRuta(gps, tr('Tu ubicación', 'Your location'), seguirGPS: true);
    } else {
      _calcularRuta(_ciudades['Guazacapán']!, 'Guazacapán', seguirGPS: false);
    }
  }

  // Calcula y dibuja la ruta desde [origen] hasta el destino.
  Future<void> _calcularRuta(LatLng origen, String nombre,
      {required bool seguirGPS}) async {
    _gps?.cancel();
    setState(() {
      _cargando = true;
      _estado = tr('Calculando la ruta…', 'Calculating route…');
    });
    final ruta = await obtenerRuta(origen, widget.destino);
    if (ruta == null || ruta.pasos.isEmpty) {
      setState(() {
        _cargando = false;
        _estado = tr('No pude calcular la ruta. Revisa tu internet.',
            'Couldn\'t calculate the route. Check your internet.');
      });
      return;
    }
    setState(() {
      _yo = origen;
      _origenNombre = nombre;
      _ruta = ruta;
      _paso = ruta.pasos.length > 1 ? 1 : 0; // 0 es "empieza el viaje"
      _cargando = false;
      _estado = ruta.pasos[_paso].instruccion;
    });
    _map.move(origen, 14);
    _hablar(tr('Ruta desde $nombre. ${_ruta!.pasos[_paso].instruccion}',
        'Route from $nombre. ${_ruta!.pasos[_paso].instruccion}'));
    if (seguirGPS) _seguirGPS(); // solo seguimos el GPS si arrancamos con él
  }

  void _seguirGPS() {
    _gps = Geolocator.getPositionStream(
      locationSettings:
          const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 8),
    ).listen((pos) {
      final yo = LatLng(pos.latitude, pos.longitude);
      setState(() => _yo = yo);
      _map.move(yo, _map.camera.zoom);
      _revisarPaso(yo);
    });
  }

  // Si ya estás cerca de la próxima maniobra, anúnciala y pasa a la siguiente.
  void _revisarPaso(LatLng yo) {
    final ruta = _ruta;
    if (ruta == null || _paso >= ruta.pasos.length) return;
    final dist = const Distance().as(LengthUnit.Meter, yo, ruta.pasos[_paso].punto);
    if (dist < 45) {
      final instr = ruta.pasos[_paso].instruccion;
      _hablar(instr);
      setState(() {
        _estado = instr;
        _paso++;
      });
    }
  }

  Future<void> _hablar(String texto) async {
    await _tts.stop();
    await _tts.speak(texto);
  }

  // Lo llama el botón 🔊. Al ser un toque DIRECTO del dedo, "desbloquea" la voz
  // en los navegadores del teléfono (que no dejan hablar sin un gesto del
  // usuario). Después de este primer toque, los avisos automáticos ya suenan.
  // OJO: sin await antes de speak, para no romper el gesto (iOS lo exige).
  void _repetirVoz() {
    setState(() => _vozLista = true);
    _tts.stop();
    _tts.speak(_estado);
  }

  @override
  void dispose() {
    _gps?.cancel();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ruta = _ruta;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Hacia ${widget.nombreDestino}',
            'To ${widget.nombreDestino}')),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.my_location),
            tooltip: tr('Elegir desde dónde salir', 'Choose where to start from'),
            onSelected: (op) {
              if (op == 'gps') {
                _iniciar(); // intenta el GPS de nuevo
              } else {
                _calcularRuta(_ciudades[op]!, op, seguirGPS: false);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: 'gps',
                  child: Text(tr('📍 Desde mi ubicación (GPS)',
                      '📍 From my location (GPS)'))),
              ..._ciudades.keys.map((c) => PopupMenuItem(
                  value: c, child: Text(tr('🏙️ Desde $c', '🏙️ From $c')))),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: _yo ?? widget.destino,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.samuel.volcanes_gt',
              ),
              if (ruta != null)
                PolylineLayer(polylines: [
                  Polyline(
                    points: ruta.puntos,
                    color: Colors.blue,
                    strokeWidth: 6,
                  ),
                ]),
              MarkerLayer(markers: [
                Marker(
                  point: widget.destino,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                ),
                if (_yo != null)
                  Marker(
                    point: _yo!,
                    width: 26,
                    height: 26,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
              ]),
            ],
          ),

          // Banner de arriba con la instrucción actual.
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Card(
              color: Colors.blue.shade700,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _cargando
                        ? const SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 3))
                        : const Icon(Icons.navigation, color: Colors.white, size: 30),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _estado,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                          // Pista que aparece hasta que tocas 🔊 la primera vez.
                          if (!_cargando && !_vozLista)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                tr('Toca 🔊 para oír las indicaciones',
                                    'Tap 🔊 to hear directions'),
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Botón de voz: desbloquea y repite la instrucción actual.
                    IconButton(
                      onPressed: _cargando ? null : _repetirVoz,
                      tooltip: tr('Escuchar la instrucción', 'Hear the instruction'),
                      icon: const Icon(Icons.volume_up,
                          color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tarjeta de abajo con distancia/tiempo y botón terminar.
          if (ruta != null)
            Positioned(
              bottom: 16,
              left: 12,
              right: 12,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.route, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${ruta.distanciaKm.toStringAsFixed(1)} km  ·  ${ruta.duracionMin} min',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(tr('Desde $_origenNombre', 'From $_origenNombre'),
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        label: Text(tr('Terminar', 'End')),
                        style: FilledButton.styleFrom(
                            backgroundColor: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
