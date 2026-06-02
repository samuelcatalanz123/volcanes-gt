import 'package:latlong2/latlong.dart';

/// Un departamento de Guatemala, ubicado en su cabecera (capital).
class Departamento {
  final String nombre;
  final String cabecera;
  final double lat;
  final double lng;
  const Departamento(this.nombre, this.cabecera, this.lat, this.lng);

  LatLng get punto => LatLng(lat, lng);
}

/// Los 22 departamentos de Guatemala (ubicados en su cabecera departamental).
const List<Departamento> departamentos = [
  Departamento('Guatemala', 'Ciudad de Guatemala', 14.6349, -90.5069),
  Departamento('Sacatepéquez', 'Antigua Guatemala', 14.5586, -90.7339),
  Departamento('Chimaltenango', 'Chimaltenango', 14.6611, -90.8194),
  Departamento('Escuintla', 'Escuintla', 14.3050, -90.7850),
  Departamento('Santa Rosa', 'Cuilapa', 14.2783, -90.2983),
  Departamento('Sololá', 'Sololá', 14.7722, -91.1828),
  Departamento('Totonicapán', 'Totonicapán', 14.9117, -91.3611),
  Departamento('Quetzaltenango', 'Quetzaltenango', 14.8347, -91.5181),
  Departamento('Suchitepéquez', 'Mazatenango', 14.5347, -91.5039),
  Departamento('Retalhuleu', 'Retalhuleu', 14.5361, -91.6778),
  Departamento('San Marcos', 'San Marcos', 14.9667, -91.7944),
  Departamento('Huehuetenango', 'Huehuetenango', 15.3197, -91.4711),
  Departamento('Quiché', 'Santa Cruz del Quiché', 15.0306, -91.1497),
  Departamento('Baja Verapaz', 'Salamá', 15.1036, -90.3158),
  Departamento('Alta Verapaz', 'Cobán', 15.4708, -90.3711),
  Departamento('Petén', 'Flores', 16.9281, -89.8917),
  Departamento('Izabal', 'Puerto Barrios', 15.7278, -88.5944),
  Departamento('Zacapa', 'Zacapa', 14.9722, -89.5306),
  Departamento('Chiquimula', 'Chiquimula', 14.8000, -89.5450),
  Departamento('Jalapa', 'Jalapa', 14.6333, -89.9889),
  Departamento('Jutiapa', 'Jutiapa', 14.2906, -89.8956),
  Departamento('El Progreso', 'Guastatoya', 14.8556, -90.0681),
];
