# Diseño — "Volcanes GT" (mapa de volcanes de Guatemala para turistas)

**Fecha:** 2026-06-02
**Autor:** Samuel
**Tipo:** App móvil (Flutter / Dart)

## Objetivo

Una app de teléfono con un **mapa de Guatemala** que muestra los **volcanes** y
la **ubicación del turista (GPS)**, con información de cada volcán, para que los
turistas los encuentren y no se pierdan.

## Para quién

Turistas que visitan Guatemala (y cualquiera curioso de los volcanes). Un solo
tipo de usuario; no hay cuentas (es una app de consulta).

## Alcance (versión 1 — MVP)

Incluye:

1. **Mapa de Guatemala** (OpenStreetMap, gratis) centrado en el país.
2. Un **marcador 🔺 por cada volcán** principal.
3. **Ubicación del usuario (GPS)**: pide permiso y muestra un punto donde está.
4. Tocar un volcán → **tarjeta** con: nombre, altura, departamento, si está
   activo, y un **consejo para turistas**.
5. Botón **📍 "Centrar en mí"** para volver a la ubicación del usuario.

NO incluye (v2 / futuro):

- Fotos de los volcanes.
- Rutas / "cómo llegar".
- Buscador, favoritos, mapas offline.
- Cuentas de usuario (no hacen falta).

## Pantallas

1. **Mapa (pantalla principal)** — ocupa toda la pantalla:
   - Tiles de OpenStreetMap.
   - Marcadores de volcanes (🔺) y del usuario (punto azul).
   - Botón flotante "📍 Centrar en mí".
2. **Tarjeta de info del volcán** — aparece desde abajo (bottom sheet) al tocar
   un marcador: nombre, altura, departamento, estado (activo/inactivo), consejo,
   y un botón para cerrarla.

## Datos

Un **`Volcan`**:

| Campo         | Tipo    | Notas                                  |
|---------------|---------|----------------------------------------|
| `nombre`      | String  | ej. "Volcán de Pacaya"                 |
| `lat`         | double  | latitud                                |
| `lng`         | double  | longitud                               |
| `alturaM`     | int     | altura en metros                       |
| `departamento`| String  | ej. "Escuintla"                        |
| `activo`      | bool    | si es un volcán activo                 |
| `consejo`     | String  | consejo corto para turistas            |

La lista de volcanes va **dentro de la app** (en `lib/data/volcanes.dart`): no
necesita internet para los datos ni servidor. Volcanes incluidos: Pacaya,
Fuego, Acatenango, Agua, Atitlán, San Pedro, Tolimán, Santa María, Tajumulco,
Tacaná (coordenadas y datos aproximados; se pueden afinar).

## Tecnología

- **Flutter** (Dart).
- **`flutter_map`** + **OpenStreetMap** — mapa gratis, sin API key ni tarjeta.
- **`latlong2`** — tipo de coordenadas que usa flutter_map.
- **`geolocator`** — ubicación del usuario (GPS), con manejo de permisos.

## Permisos / detalles

- Al abrir, pedir permiso de ubicación. Si el usuario lo niega, la app **igual
  funciona** (muestra el mapa y los volcanes, solo sin el punto azul).
- En navegador (para probar) el GPS usa el permiso del navegador; en un teléfono
  real usa el GPS del sistema.

## Estructura del código

- `lib/models/volcan.dart` — el modelo `Volcan`.
- `lib/data/volcanes.dart` — la lista de volcanes.
- `lib/screens/mapa_screen.dart` — el mapa, marcadores y ubicación.
- `lib/widgets/volcan_info.dart` — la tarjeta de info (bottom sheet).
- `lib/main.dart` — arranque de la app.

## Criterios de éxito

- La app abre mostrando el mapa de Guatemala con los volcanes marcados.
- Al dar permiso, aparece mi ubicación; si lo niego, la app sigue funcionando.
- Toco un volcán y veo su info (altura, departamento, activo, consejo).
- El botón "Centrar en mí" me lleva a mi ubicación.
- Corre con `flutter run` (web para probar; luego en teléfono).

## Nota sobre publicar y dinero (importante, Samuel tiene 15)

Construir la app = ahora. **Publicarla en la tienda y cobrar dinero** requiere
la cuenta de un adulto (18+): tus papás o tu jefe. Cuéntales del trabajo y deja
que ellos manejen el dinero, los acuerdos y la publicación. Seguridad primero.
