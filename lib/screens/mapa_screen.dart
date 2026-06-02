import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/volcanes.dart';
import '../data/lugares.dart';
import '../data/departamentos.dart';
import '../data/frontera.dart';
import '../models/lugar.dart';
import '../services/ubicacion.dart';
import '../services/gasolineras.dart';
import '../widgets/volcan_info.dart';
import '../widgets/lugar_info.dart';

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
  // Qué cosas se muestran en el mapa (los botones de abajo las prenden/apagan).
  bool _verVolcanes = true;
  bool _verDepartamentos = false; // los 22 departamentos (apagado por defecto)
  final Set<TipoLugar> _tiposVisibles = {...TipoLugar.values};
  // Gasolineras y aldeas traídas de internet (OpenStreetMap) + estados de carga.
  List<PuntoOSM> _gasolineras = [];
  List<PuntoOSM> _aldeas = [];
  List<Rio> _rios = [];
  bool _cargandoGaso = false;
  bool _cargandoAldeas = false;
  bool _cargandoRios = false;
  // El volcán más alto de la lista (para marcarlo con una estrella).
  static final _masAlto =
      volcanes.reduce((a, b) => a.alturaM >= b.alturaM ? a : b);

  // Frontera REAL de Guatemala en alta resolución (275 puntos, ver frontera.dart).
  // Sirve para resaltar el país y tapar lo de afuera, sin cortar terreno real.
  static final _bordeGuatemala = fronteraGuatemala;

  // Un rectángulo MUY grande que cubre toda la región (México, Centroamérica
  // y mares), con un "agujero" en forma de Guatemala. Pintado sólido, tapa por
  // completo a los países vecinos: solo se ve Guatemala.
  static final _afuera = <LatLng>[
    LatLng(2.0, -108.0),
    LatLng(2.0, -75.0),
    LatLng(30.0, -75.0),
    LatLng(30.0, -108.0),
  ];

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

  // Vuelve a mostrar todo Guatemala (encaja el mapa en los límites del país).
  void _verTodoGuatemala() {
    _mapController.fitCamera(CameraFit.bounds(bounds: _limitesGuate));
  }

  // Pide a OpenStreetMap las gasolineras de la zona que se ve ahora.
  Future<void> _buscarGasolineras() => _buscarEnZona(
        nombre: 'gasolineras',
        emoji: '⛽',
        buscar: buscarGasolineras,
        guardar: (lista) => _gasolineras = lista,
        marcarCargando: (v) => _cargandoGaso = v,
      );

  // Pide a OpenStreetMap las aldeas de la zona que se ve ahora.
  Future<void> _buscarAldeas() => _buscarEnZona(
        nombre: 'aldeas',
        emoji: '🏘️',
        buscar: buscarAldeas,
        guardar: (lista) => _aldeas = lista,
        marcarCargando: (v) => _cargandoAldeas = v,
      );

  // Pide a OpenStreetMap los ríos de la zona visible y los dibuja como líneas.
  Future<void> _buscarRios() async {
    final camara = _mapController.camera;
    if (camara.zoom < 9) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Acércate más al mapa para buscar ríos 🏞️'),
      ));
      return;
    }
    setState(() => _cargandoRios = true);
    try {
      final encontrados = await buscarRios(camara.visibleBounds);
      if (!mounted) return;
      setState(() => _rios = encontrados);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Se encontraron ${encontrados.length} ríos 🏞️'),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No se pudieron cargar los ríos. Intenta otra vez.'),
      ));
    } finally {
      if (mounted) setState(() => _cargandoRios = false);
    }
  }

  // Lógica común: pide acercarse (en todo el país serían miles), llama a la
  // API, guarda el resultado y avisa cuántos encontró o si hubo error.
  Future<void> _buscarEnZona({
    required String nombre,
    required String emoji,
    required Future<List<PuntoOSM>> Function(LatLngBounds) buscar,
    required void Function(List<PuntoOSM>) guardar,
    required void Function(bool) marcarCargando,
  }) async {
    final camara = _mapController.camera;
    if (camara.zoom < 11) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Acércate más al mapa para buscar $nombre $emoji'),
      ));
      return;
    }
    setState(() => marcarCargando(true));
    try {
      final encontrados = await buscar(camara.visibleBounds);
      if (!mounted) return;
      setState(() => guardar(encontrados));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Se encontraron ${encontrados.length} $nombre $emoji'),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No se pudieron cargar las $nombre. Intenta otra vez.'),
      ));
    } finally {
      if (mounted) setState(() => marcarCargando(false));
    }
  }

  // Abre una lista de los volcanes ordenados del más alto al más bajo,
  // con un buscador que filtra mientras escribes. Al tocar uno, cierra la
  // lista y vuela hacia ese volcán en el mapa.
  void _mostrarLista() {
    final ordenados = [...volcanes]
      ..sort((a, b) => b.alturaM.compareTo(a.alturaM));
    String busqueda = ''; // lo que el usuario escribe en el buscador

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true, // para que crezca con el teclado
      builder: (context) {
        // StatefulBuilder permite que la hoja se redibuje al escribir.
        return StatefulBuilder(
          builder: (context, setSheetState) {
            // Filtra por nombre o departamento (sin importar mayúsculas).
            final q = busqueda.toLowerCase();
            final filtrados = ordenados
                .where((v) =>
                    v.nombre.toLowerCase().contains(q) ||
                    v.departamento.toLowerCase().contains(q))
                .toList();

            return Padding(
              // Deja espacio cuando aparece el teclado.
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: TextField(
                      autofocus: false,
                      decoration: const InputDecoration(
                        labelText: 'Buscar volcán o departamento',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (texto) =>
                          setSheetState(() => busqueda = texto),
                    ),
                  ),
                  Flexible(
                    child: filtrados.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('No se encontró ningún volcán.'),
                          )
                        : ListView(
                            shrinkWrap: true,
                            children: [
                              for (final v in filtrados)
                                ListTile(
                                  // Foto pequeña del volcán (o ícono si no hay).
                                  leading: v.foto != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: Image.network(
                                            v.foto!,
                                            width: 54,
                                            height: 54,
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) => Icon(
                                              v.activo
                                                  ? Icons.local_fire_department
                                                  : Icons.terrain,
                                              color: v.activo
                                                  ? Colors.red
                                                  : Colors.deepOrange,
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          v.activo
                                              ? Icons.local_fire_department
                                              : Icons.terrain,
                                          color: v.activo
                                              ? Colors.red
                                              : Colors.deepOrange,
                                        ),
                                  title: Text(v.nombre),
                                  subtitle: Text(
                                      '${v.alturaM} m  ·  ${v.departamento}'),
                                  trailing: v == _masAlto
                                      ? const Icon(Icons.star,
                                          color: Colors.amber)
                                      : null,
                                  onTap: () {
                                    Navigator.pop(context); // cierra la lista
                                    mostrarVolcanInfo(context, v,
                                        desde: _yo); // abre la ficha con foto
                                  },
                                ),
                            ],
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🌋 ${volcanes.length} Volcanes de Guatemala'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'Lista por altura',
            onPressed: _mostrarLista,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _centroGuate,
          initialZoom: 7.5,
          // El mapa permite acercarse mucho (hasta zoom 18) para ver pueblos.
          // containCenter: solo el CENTRO debe quedar dentro de Guatemala, así
          // SÍ se puede mover y acercar libremente (contain lo trababa todo).
          minZoom: 6,
          maxZoom: 18,
          cameraConstraint:
              CameraConstraint.containCenter(bounds: _limitesGuate),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.samuel.volcanes_gt',
          ),
          // Máscara: oscurece todo MENOS Guatemala, y dibuja su borde.
          PolygonLayer(
            polygons: [
              Polygon(
                points: _afuera,
                holePointsList: [_bordeGuatemala], // el agujero = Guatemala
                // Color SÓLIDO (sin transparencia): tapa del todo a los vecinos.
                color: const Color(0xFFDDE6EC), // gris-azulado neutro
              ),
              Polygon(
                points: _bordeGuatemala,
                borderColor: Colors.deepOrange,
                borderStrokeWidth: 2.5,
                color: Colors.transparent,
              ),
            ],
          ),
          // Ríos (líneas azules) traídos de internet.
          PolylineLayer(
            polylines: [
              for (final r in _rios)
                Polyline(
                  points: r.puntos,
                  color: Colors.blue.shade600,
                  strokeWidth: 2.5,
                ),
            ],
          ),
          MarkerLayer(
            markers: [
              // Un marcador por cada volcán: el ícono de fuego + su nombre debajo.
              if (_verVolcanes)
              for (final v in volcanes)
                Marker(
                  point: v.punto,
                  width: 120,
                  height: 84,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque, // toda la zona toca
                    onTap: () => mostrarVolcanInfo(context, v, desde: _yo),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Estrella amarilla sobre el volcán más alto.
                        if (v == _masAlto)
                          const Icon(Icons.star,
                              color: Colors.amber, size: 16),
                        // Activo = fuego rojo; apagado = montaña naranja.
                        Icon(
                            v.activo
                                ? Icons.local_fire_department
                                : Icons.terrain,
                            color: v.activo ? Colors.red : Colors.deepOrange,
                            size: 32),
                        // Etiqueta blanca con el nombre y la altura para ver dónde está.
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                v.nombre.replaceFirst('Volcán de ', ''),
                                style: const TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${v.alturaM} m',
                                style: const TextStyle(
                                    fontSize: 9, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Un marcador por cada lugar (lago/playa/montaña) que esté visible.
              for (final l in lugares)
                if (_tiposVisibles.contains(l.tipo))
                  Marker(
                    point: l.punto,
                    width: 120,
                    height: 54,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque, // toda la zona toca
                      onTap: () => mostrarLugarInfo(context, l),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(iconoDe(l.tipo),
                              color: colorDe(l.tipo), size: 28),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              l.nombre,
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
              // Los 22 departamentos (en su cabecera), si están activados.
              if (_verDepartamentos)
                for (final d in departamentos)
                  Marker(
                    point: d.punto,
                    width: 130,
                    height: 40,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Departamento de ${d.nombre} · cabecera: ${d.cabecera}'))),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_city,
                              color: Colors.indigo, size: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.indigo.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              d.nombre,
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              // Aldeas traídas de internet (🏘️ morado).
              for (final a in _aldeas)
                Marker(
                  point: a.punto,
                  width: 36,
                  height: 36,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('🏘️ Aldea: ${a.nombre}'))),
                    child: const Icon(Icons.holiday_village,
                        color: Colors.purple, size: 24),
                  ),
                ),
              // Gasolineras traídas de internet (⛽ verde).
              for (final g in _gasolineras)
                Marker(
                  point: g.punto,
                  width: 36,
                  height: 36,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('⛽ ${g.nombre}'))),
                    child: const Icon(Icons.local_gas_station,
                        color: Colors.green, size: 28),
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
          // Leyenda de colores arriba a la izquierda.
          const Positioned(top: 12, left: 12, child: _Leyenda()),
          // Botones (abajo) para mostrar/ocultar cada tipo de lugar.
          Positioned(
            bottom: 12,
            left: 12,
            right: 90,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    avatar: const Icon(Icons.local_fire_department,
                        color: Colors.red, size: 18),
                    label: const Text('Volcanes'),
                    selected: _verVolcanes,
                    onSelected: (v) => setState(() => _verVolcanes = v),
                  ),
                  for (final tipo in TipoLugar.values) ...[
                    const SizedBox(width: 6),
                    FilterChip(
                      avatar: Icon(iconoDe(tipo),
                          color: colorDe(tipo), size: 18),
                      label: Text(nombreTipo(tipo)),
                      selected: _tiposVisibles.contains(tipo),
                      onSelected: (v) => setState(() {
                        if (v) {
                          _tiposVisibles.add(tipo);
                        } else {
                          _tiposVisibles.remove(tipo);
                        }
                      }),
                    ),
                  ],
                  const SizedBox(width: 6),
                  FilterChip(
                    avatar: const Icon(Icons.location_city,
                        color: Colors.indigo, size: 18),
                    label: const Text('Departamentos'),
                    selected: _verDepartamentos,
                    onSelected: (v) =>
                        setState(() => _verDepartamentos = v),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón para buscar ríos en la zona visible (de internet).
          FloatingActionButton(
            heroTag: 'rios',
            backgroundColor: Colors.blue,
            onPressed: _cargandoRios ? null : _buscarRios,
            tooltip: 'Buscar ríos aquí',
            child: _cargandoRios
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.water),
          ),
          const SizedBox(height: 12),
          // Botón para buscar aldeas en la zona visible (de internet).
          FloatingActionButton(
            heroTag: 'aldeas',
            backgroundColor: Colors.purple,
            onPressed: _cargandoAldeas ? null : _buscarAldeas,
            tooltip: 'Buscar aldeas aquí',
            child: _cargandoAldeas
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.holiday_village),
          ),
          const SizedBox(height: 12),
          // Botón para buscar gasolineras en la zona visible (de internet).
          FloatingActionButton(
            heroTag: 'gaso',
            backgroundColor: Colors.green,
            onPressed: _cargandoGaso ? null : _buscarGasolineras,
            tooltip: 'Buscar gasolineras aquí',
            child: _cargandoGaso
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.local_gas_station),
          ),
          const SizedBox(height: 12),
          // Botón para volver a ver todo el país.
          FloatingActionButton(
            heroTag: 'todo',
            onPressed: _verTodoGuatemala,
            tooltip: 'Ver todo Guatemala',
            child: const Icon(Icons.public),
          ),
          const SizedBox(height: 12),
          // Botón para centrar en mi ubicación.
          FloatingActionButton(
            heroTag: 'yo',
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
        ],
      ),
    );
  }
}

// Caja pequeña que explica qué significan los colores de los volcanes.
class _Leyenda extends StatelessWidget {
  const _Leyenda();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.local_fire_department, color: Colors.red, size: 18),
            SizedBox(width: 4),
            Text('Activo', style: TextStyle(fontSize: 12)),
          ]),
          SizedBox(height: 2),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.terrain, color: Colors.deepOrange, size: 18),
            SizedBox(width: 4),
            Text('Apagado', style: TextStyle(fontSize: 12)),
          ]),
          SizedBox(height: 2),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.star, color: Colors.amber, size: 18),
            SizedBox(width: 4),
            Text('Más alto', style: TextStyle(fontSize: 12)),
          ]),
        ],
      ),
    );
  }
}
