# Volcanes GT — Plan de Implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** App Flutter con un mapa de Guatemala que muestra los volcanes y la ubicación del usuario (GPS); al tocar un volcán, su info para turistas.

**Architecture:** Flutter con `flutter_map` + OpenStreetMap (mapa gratis, sin API key). Datos de los volcanes en una lista dentro de la app (sin servidor). Ubicación con `geolocator`. Estado con `setState`.

**Tech Stack:** Flutter, Dart, flutter_map, latlong2, geolocator.

---

## Estructura de archivos

- `pubspec.yaml` — dependencias (flutter_map, latlong2, geolocator).
- `lib/models/volcan.dart` — el modelo `Volcan`.
- `lib/data/volcanes.dart` — la lista de volcanes de Guatemala.
- `lib/services/ubicacion.dart` — obtener la ubicación del usuario (GPS).
- `lib/widgets/volcan_info.dart` — la tarjeta de info (bottom sheet).
- `lib/screens/mapa_screen.dart` — el mapa con marcadores y ubicación.
- `lib/main.dart` — arranque de la app.
- `test/volcanes_test.dart` — pruebas de los datos.

---

### Task 0: Crear el proyecto Flutter + dependencias

**Files:** Create: esqueleto Flutter en `/Users/mqr93ea/Repos/volcanes-gt`

- [ ] **Step 1: Crear el proyecto**

Run:
```bash
cd /Users/mqr93ea/Repos/volcanes-gt
flutter create --project-name volcanes_gt --platforms web .
```
Expected: crea `lib/`, `pubspec.yaml`, `web/`, etc. (no borra `docs/`).

- [ ] **Step 2: Agregar dependencias**

Run:
```bash
flutter pub add flutter_map latlong2 geolocator
```
Expected: aparecen en `pubspec.yaml`.

- [ ] **Step 3: Quitar el test de ejemplo y verificar**

Run:
```bash
rm -f test/widget_test.dart
flutter analyze
```
Expected: "No issues found!"

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "chore: scaffold Flutter + deps (flutter_map, latlong2, geolocator)"
```

---

### Task 1: Modelo `Volcan`

**Files:** Create: `lib/models/volcan.dart`

- [ ] **Step 1: Escribir el modelo**

```dart
// lib/models/volcan.dart
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
```

- [ ] **Step 2: Verificar que compila**

Run: `flutter analyze`
Expected: "No issues found!"

- [ ] **Step 3: Commit**

```bash
git add lib/models/volcan.dart
git commit -m "feat: modelo Volcan"
```

---

### Task 2: Datos de los volcanes + test

**Files:** Create: `lib/data/volcanes.dart`, `test/volcanes_test.dart`

- [ ] **Step 1: Escribir el test que falla**

```dart
// test/volcanes_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:volcanes_gt/data/volcanes.dart';

void main() {
  test('hay varios volcanes y todos tienen datos válidos', () {
    expect(volcanes.length, greaterThanOrEqualTo(8));
    for (final v in volcanes) {
      expect(v.nombre.isNotEmpty, true, reason: 'nombre vacío');
      expect(v.alturaM, greaterThan(0), reason: '${v.nombre} sin altura');
      // Coordenadas dentro de Guatemala (aprox).
      expect(v.lat, inInclusiveRange(13.5, 18.0), reason: '${v.nombre} lat fuera de rango');
      expect(v.lng, inInclusiveRange(-92.5, -88.0), reason: '${v.nombre} lng fuera de rango');
      expect(v.consejo.isNotEmpty, true, reason: '${v.nombre} sin consejo');
    }
  });
}
```

- [ ] **Step 2: Correr y verlo fallar**

Run: `flutter test test/volcanes_test.dart`
Expected: FAIL — no existe `volcanes`.

- [ ] **Step 3: Escribir la lista de volcanes**

```dart
// lib/data/volcanes.dart
import '../models/volcan.dart';

/// Volcanes principales de Guatemala (coordenadas y datos aproximados).
const List<Volcan> volcanes = [
  Volcan(nombre: 'Volcán de Pacaya', lat: 14.382, lng: -90.601, alturaM: 2552, departamento: 'Escuintla', activo: true, consejo: 'Muy visitado y accesible. Lleva agua y zapatos cómodos; revisa la actividad antes de subir.'),
  Volcan(nombre: 'Volcán de Fuego', lat: 14.473, lng: -90.880, alturaM: 3763, departamento: 'Chimaltenango', activo: true, consejo: 'Activo y peligroso: NO se sube. Se observa desde el Acatenango con guía.'),
  Volcan(nombre: 'Volcán Acatenango', lat: 14.501, lng: -90.876, alturaM: 3976, departamento: 'Chimaltenango', activo: false, consejo: 'Caminata de 1-2 días con guía. Hace mucho frío de noche; lleva abrigo.'),
  Volcan(nombre: 'Volcán de Agua', lat: 14.465, lng: -90.743, alturaM: 3760, departamento: 'Sacatepéquez', activo: false, consejo: 'Vistas a Antigua. Sube con guía y empieza temprano.'),
  Volcan(nombre: 'Volcán Atitlán', lat: 14.583, lng: -91.186, alturaM: 3535, departamento: 'Sololá', activo: false, consejo: 'Junto al lago de Atitlán. Caminata exigente; contrata guía local.'),
  Volcan(nombre: 'Volcán San Pedro', lat: 14.655, lng: -91.270, alturaM: 3020, departamento: 'Sololá', activo: false, consejo: 'Tiene parque y sendero marcado. Buen mirador del lago.'),
  Volcan(nombre: 'Volcán Tolimán', lat: 14.612, lng: -91.189, alturaM: 3158, departamento: 'Sololá', activo: false, consejo: 'Menos visitado; sendero difícil. Ve con guía.'),
  Volcan(nombre: 'Volcán Santa María', lat: 14.756, lng: -91.552, alturaM: 3772, departamento: 'Quetzaltenango', activo: true, consejo: 'Cerca de Xela. Desde la cima se ve el domo activo Santiaguito.'),
  Volcan(nombre: 'Volcán Tajumulco', lat: 15.043, lng: -91.903, alturaM: 4220, departamento: 'San Marcos', activo: false, consejo: 'El punto más alto de Centroamérica. Mucho frío; aclimátate a la altura.'),
  Volcan(nombre: 'Volcán Tacaná', lat: 15.132, lng: -92.109, alturaM: 4060, departamento: 'San Marcos', activo: true, consejo: 'En la frontera con México. Caminata larga; planifica con guía.'),
];
```

- [ ] **Step 4: Correr y verlo pasar**

Run: `flutter test test/volcanes_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/data/volcanes.dart test/volcanes_test.dart
git commit -m "feat: datos de los volcanes de Guatemala + test"
```

---

### Task 3: Servicio de ubicación (GPS)

**Files:** Create: `lib/services/ubicacion.dart`

- [ ] **Step 1: Escribir el servicio**

```dart
// lib/services/ubicacion.dart
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
```

- [ ] **Step 2: Verificar que compila**

Run: `flutter analyze`
Expected: "No issues found!"

- [ ] **Step 3: Commit**

```bash
git add lib/services/ubicacion.dart
git commit -m "feat: servicio de ubicación (geolocator)"
```

---

### Task 4: Tarjeta de info del volcán

**Files:** Create: `lib/widgets/volcan_info.dart`

- [ ] **Step 1: Escribir el widget**

```dart
// lib/widgets/volcan_info.dart
import 'package:flutter/material.dart';
import '../models/volcan.dart';

/// Muestra la info de un volcán en una hoja inferior (bottom sheet).
void mostrarVolcanInfo(BuildContext context, Volcan v) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(v.nombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.terrain, size: 18),
            const SizedBox(width: 6),
            Text('${v.alturaM} m  ·  ${v.departamento}'),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Icon(v.activo ? Icons.local_fire_department : Icons.check_circle,
                size: 18, color: v.activo ? Colors.red : Colors.green),
            const SizedBox(width: 6),
            Text(v.activo ? 'Volcán ACTIVO' : 'Inactivo'),
          ]),
          const SizedBox(height: 12),
          Text(v.consejo, style: const TextStyle(height: 1.4)),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 2: Verificar que compila**

Run: `flutter analyze`
Expected: "No issues found!"

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/volcan_info.dart
git commit -m "feat: tarjeta de info del volcán"
```

---

### Task 5: Pantalla del mapa

**Files:** Create: `lib/screens/mapa_screen.dart`

- [ ] **Step 1: Escribir la pantalla**

```dart
// lib/screens/mapa_screen.dart
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
        options: MapOptions(initialCenter: _centroGuate, initialZoom: 7.5),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.samuel.volcanes_gt',
          ),
          MarkerLayer(
            markers: [
              // Un marcador por cada volcán.
              for (final v in volcanes)
                Marker(
                  point: v.punto,
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => mostrarVolcanInfo(context, v),
                    child: Icon(Icons.local_fire_department,
                        color: v.activo ? Colors.red : Colors.deepOrange, size: 36),
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
```

- [ ] **Step 2: Verificar que compila**

Run: `flutter analyze`
Expected: "No issues found!"

- [ ] **Step 3: Commit**

```bash
git add lib/screens/mapa_screen.dart
git commit -m "feat: pantalla del mapa con volcanes y ubicación"
```

---

### Task 6: main.dart + correr la app

**Files:** Modify: `lib/main.dart`

- [ ] **Step 1: Reemplazar main.dart**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/mapa_screen.dart';

void main() => runApp(const VolcanesApp());

class VolcanesApp extends StatelessWidget {
  const VolcanesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volcanes GT',
      theme: ThemeData(colorSchemeSeed: Colors.deepOrange, useMaterial3: true),
      home: const MapaScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

- [ ] **Step 2: Analizar y correr los tests**

Run: `flutter analyze && flutter test`
Expected: "No issues found!" y los tests pasan.

- [ ] **Step 3: Correr la app y probarla**

Run: `flutter run -d web-server --web-port 8097`
Abrir `http://localhost:8097`:
- Se ve el mapa de Guatemala con 🔥 en cada volcán.
- El navegador pide permiso de ubicación; al aceptar, aparece un punto azul y el mapa se centra en ti.
- Tocar un volcán → sale la tarjeta con su info (altura, departamento, activo, consejo).
- El botón "Centrar en mí" te lleva a tu ubicación.
- Si niegas el permiso, el mapa y los volcanes igual funcionan.

- [ ] **Step 4: Commit**

```bash
git add lib/main.dart
git commit -m "feat: app Volcanes GT funcionando (main + mapa)"
```

---

## Notas
- `flutter_map` usa tiles de OpenStreetMap (gratis, sin API key). Incluir
  `userAgentPackageName` es buena práctica.
- En el navegador, el GPS usa el permiso del navegador; en un teléfono real, el
  GPS del sistema. La app funciona aunque se niegue el permiso (sin punto azul).
- Coordenadas/datos de los volcanes son aproximados; se pueden afinar.
- Publicar en la tienda y cobrar = cuenta de un adulto (ver el spec).
