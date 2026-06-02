# 🌋 Volcanes GT

Mapa interactivo de los **volcanes y lugares turísticos de Guatemala**, hecho en
Flutter. Pensado para turistas: muestra dónde están los volcanes, lagos, playas
y montañas, con fotos, información y datos en vivo.

> Creado por **Samuel Catalán** — creador del mapa de Guatemala y muchos proyectos más. 🇬🇹

## ✨ Qué hace

- 🗺️ Mapa centrado **solo en Guatemala** (con su frontera real resaltada).
- 🔥 **25 volcanes** con nombre, altura, departamento y un consejo para el turista.
- 🏛️ Los **22 departamentos** del país.
- 💧🏖️⛰️ **Lagos, playas y montañas** famosas, con fotos.
- 📷 **Fotos reales** de cada lugar (de Wikimedia, uso libre).
- 📍 **Ubicación del usuario (GPS)** y distancia en km a cada volcán.
- 🌤️ **Clima actual** de cada volcán (en vivo).
- 📋 **Lista** ordenada por altura, con **buscador**.
- ⛽🏘️🏞️ **Gasolineras, aldeas y ríos reales** traídos de internet por zona.
- 🎛️ **Filtros** para mostrar/ocultar cada tipo de lugar.
- 📱 Instalable como app (**PWA**).

## 🛠️ Tecnología

- **Flutter / Dart**
- **flutter_map** + **OpenStreetMap** (mapa gratis, sin API key)
- **geolocator** (GPS)
- **API Overpass** de OpenStreetMap (gasolineras, aldeas, ríos)
- **Open-Meteo** (clima)
- **Wikimedia** (fotos)

## ▶️ Cómo correrlo

```bash
flutter pub get
flutter run -d chrome      # o: flutter run
```

## 📄 Datos

Datos de OpenStreetMap, Open-Meteo y Wikimedia — todos de uso libre.
