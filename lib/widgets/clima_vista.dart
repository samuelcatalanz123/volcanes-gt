import 'package:flutter/material.dart';
import '../services/clima.dart';
import '../services/idioma.dart';

/// Muestra el clima actual de unas coordenadas y, debajo, el pronóstico de los
/// próximos días. Mientras carga muestra un aviso; si falla, uno amable.
class ClimaVista extends StatelessWidget {
  final double lat;
  final double lng;
  const ClimaVista({super.key, required this.lat, required this.lng});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _climaActual(),
        const SizedBox(height: 10),
        _pronostico(),
      ],
    );
  }

  // Clima de ahora.
  Widget _climaActual() {
    return FutureBuilder<Clima?>(
      future: obtenerClima(lat, lng),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return Row(children: [
            const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 8),
            Text(tr('Cargando clima…', 'Loading weather…')),
          ]);
        }
        final clima = snap.data;
        if (clima == null) {
          return Row(children: [
            const Icon(Icons.cloud_off, size: 18, color: Colors.grey),
            const SizedBox(width: 6),
            Text(tr('Clima no disponible', 'Weather unavailable')),
          ]);
        }
        return Row(children: [
          Text(clima.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text('${clima.tempC.toStringAsFixed(1)} °C · ${clima.descripcion}'),
        ]);
      },
    );
  }

  // Pronóstico de los próximos días (si carga; si no, no muestra nada).
  Widget _pronostico() {
    return FutureBuilder<List<DiaClima>?>(
      future: obtenerPronostico(lat, lng),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        final dias = snap.data;
        if (dias == null || dias.isEmpty) return const SizedBox.shrink();
        return Row(
          children: [
            for (var i = 0; i < dias.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(child: _DiaCard(dia: dias[i], esHoy: i == 0)),
            ],
          ],
        );
      },
    );
  }
}

/// Tarjeta pequeña de un día: nombre del día, emoji y máx/mín.
class _DiaCard extends StatelessWidget {
  final DiaClima dia;
  final bool esHoy;
  const _DiaCard({required this.dia, required this.esHoy});

  String get _nombreDia {
    if (esHoy) return tr('Hoy', 'Today');
    const es = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final i = dia.fecha.weekday - 1;
    return Idioma.esIngles ? en[i] : es[i];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_nombreDia,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(dia.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 2),
          Text('${dia.maxC.round()}°',
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold)),
          Text('${dia.minC.round()}°',
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}
