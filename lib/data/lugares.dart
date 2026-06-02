import '../models/lugar.dart';

/// Lugares turísticos famosos de Guatemala (coordenadas y datos aproximados).
const List<Lugar> lugares = [
  // ---- Lagos 💧 ----
  Lugar(
    nombre: 'Lago de Atitlán',
    lat: 14.69,
    lng: -91.20,
    tipo: TipoLugar.lago,
    departamento: 'Sololá',
    descripcion: 'Lago rodeado de volcanes, uno de los más bellos del mundo.',
    foto: 'https://commons.wikimedia.org/wiki/Special:FilePath/Lago%20de%20Atitlan.jpg?width=600',
  ),
  Lugar(
    nombre: 'Lago de Izabal',
    lat: 15.50,
    lng: -89.16,
    tipo: TipoLugar.lago,
    departamento: 'Izabal',
    descripcion: 'El lago más grande de Guatemala; cerca del Río Dulce.',
    foto: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f5/Castillo_De_San_Felipe.JPG/330px-Castillo_De_San_Felipe.JPG',
  ),
  Lugar(
    nombre: 'Lago Petén Itzá',
    lat: 16.98,
    lng: -89.83,
    tipo: TipoLugar.lago,
    departamento: 'Petén',
    descripcion: 'Gran lago del norte; cerca de la isla de Flores y Tikal.',
    foto: 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/df/Petencito%2C_Zoo%2C_Lago_Pet%C3%A9n_Itza%2C_Guatemala_-_panoramio.jpg/330px-Petencito%2C_Zoo%2C_Lago_Pet%C3%A9n_Itza%2C_Guatemala_-_panoramio.jpg',
  ),
  Lugar(
    nombre: 'Lago de Amatitlán',
    lat: 14.43,
    lng: -90.58,
    tipo: TipoLugar.lago,
    departamento: 'Guatemala',
    descripcion: 'Lago cercano a la capital, al pie del volcán de Pacaya.',
    foto: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/85/Lago_de_Amatitl%C3%A1n_-_51367165519.jpg/330px-Lago_de_Amatitl%C3%A1n_-_51367165519.jpg',
  ),

  // ---- Playas 🏖️ ----
  Lugar(
    nombre: 'Monterrico',
    lat: 13.89,
    lng: -90.48,
    tipo: TipoLugar.playa,
    departamento: 'Santa Rosa',
    descripcion: 'Playa de arena negra; famosa por las tortugas marinas.',
  ),
  Lugar(
    nombre: 'Champerico',
    lat: 14.30,
    lng: -91.91,
    tipo: TipoLugar.playa,
    departamento: 'Retalhuleu',
    descripcion: 'Playa del Pacífico con muelle histórico.',
    foto: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Champerico_Retalhuleu%2C_Guatemala.jpg/330px-Champerico_Retalhuleu%2C_Guatemala.jpg',
  ),
  Lugar(
    nombre: 'Las Lisas',
    lat: 13.80,
    lng: -90.23,
    tipo: TipoLugar.playa,
    departamento: 'Santa Rosa',
    descripcion: 'Playa tranquila del Pacífico, cerca de la frontera.',
  ),
  Lugar(
    nombre: 'Playa Blanca',
    lat: 15.78,
    lng: -88.60,
    tipo: TipoLugar.playa,
    departamento: 'Izabal',
    descripcion: 'Playa de arena blanca en el Caribe guatemalteco.',
  ),

  // ---- Montañas y sierras ⛰️ ----
  Lugar(
    nombre: 'Sierra de los Cuchumatanes',
    lat: 15.55,
    lng: -91.40,
    tipo: TipoLugar.montana,
    departamento: 'Huehuetenango',
    descripcion: 'La sierra no volcánica más alta de Centroamérica.',
    foto: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Sierra_de_los_Cuchumatanes01.jpg/330px-Sierra_de_los_Cuchumatanes01.jpg',
  ),
  Lugar(
    nombre: 'Sierra de las Minas',
    lat: 15.20,
    lng: -89.70,
    tipo: TipoLugar.montana,
    departamento: 'Zacapa / Alta Verapaz',
    descripcion: 'Reserva de biosfera con bosque nuboso y mucha fauna.',
  ),
];
