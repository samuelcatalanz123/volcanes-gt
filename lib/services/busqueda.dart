import 'package:latlong2/latlong.dart';
import '../data/volcanes.dart';
import '../data/lugares.dart';
import '../models/volcan.dart';
import '../models/lugar.dart';

/// Un resultado del buscador: es un volcán O un lugar turístico (ciudad, lago,
/// playa, montaña). Así la lista y el buscador muestran TODO en un solo lugar.
class ResultadoBusqueda {
  final Volcan? volcan;
  final Lugar? lugar;

  const ResultadoBusqueda.deVolcan(Volcan this.volcan) : lugar = null;
  const ResultadoBusqueda.deLugar(Lugar this.lugar) : volcan = null;

  bool get esVolcan => volcan != null;

  String get nombre => volcan?.nombre ?? lugar!.nombre;
  String get departamento => volcan?.departamento ?? lugar!.departamento;
  LatLng get punto => volcan?.punto ?? lugar!.punto;
}

/// Busca en TODO: los volcanes (ordenados del más alto al más bajo) y los
/// lugares turísticos. Filtra por nombre o por departamento, sin importar
/// mayúsculas. Con [consulta] vacía devuelve todo.
List<ResultadoBusqueda> buscarTodo(String consulta) {
  final q = consulta.trim().toLowerCase();

  bool coincide(String nombre, String departamento) =>
      q.isEmpty ||
      nombre.toLowerCase().contains(q) ||
      departamento.toLowerCase().contains(q);

  final volcanesOrdenados = [...volcanes]
    ..sort((a, b) => b.alturaM.compareTo(a.alturaM));

  return [
    for (final v in volcanesOrdenados)
      if (coincide(v.nombre, v.departamento)) ResultadoBusqueda.deVolcan(v),
    for (final l in lugares)
      if (coincide(l.nombre, l.departamento)) ResultadoBusqueda.deLugar(l),
  ];
}
