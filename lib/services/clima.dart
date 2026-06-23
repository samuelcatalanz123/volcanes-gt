import 'dart:convert';
import 'package:http/http.dart' as http;
import 'idioma.dart';

/// El clima actual de un lugar: temperatura y una descripción con emoji.
class Clima {
  final double tempC;
  final String descripcion;
  final String emoji;
  const Clima(this.tempC, this.descripcion, this.emoji);
}

/// El clima de un día del pronóstico: fecha, máxima/mínima y emoji.
class DiaClima {
  final DateTime fecha;
  final double maxC;
  final double minC;
  final String emoji;
  const DiaClima(this.fecha, this.maxC, this.minC, this.emoji);
}

/// Pide a Open-Meteo el pronóstico de los próximos días (máx/mín por día).
/// Devuelve null si falla.
Future<List<DiaClima>?> obtenerPronostico(double lat, double lng) async {
  final url = Uri.parse('https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lng'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min'
      '&timezone=auto&forecast_days=4');
  try {
    final res = await http.get(url).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final daily = data['daily'] as Map<String, dynamic>;
    final tiempos = daily['time'] as List;
    final codigos = daily['weather_code'] as List;
    final maxs = daily['temperature_2m_max'] as List;
    final mins = daily['temperature_2m_min'] as List;
    final dias = <DiaClima>[];
    for (var i = 0; i < tiempos.length; i++) {
      final (_, emoji) = _interpretarCodigo((codigos[i] as num).toInt());
      dias.add(DiaClima(
        DateTime.parse(tiempos[i] as String),
        (maxs[i] as num).toDouble(),
        (mins[i] as num).toDouble(),
        emoji,
      ));
    }
    return dias;
  } catch (_) {
    return null;
  }
}

/// Pide a Open-Meteo (gratis, sin clave) el clima actual de unas coordenadas.
/// Devuelve null si falla (no hay internet, error del servidor, etc.).
Future<Clima?> obtenerClima(double lat, double lng) async {
  final url = Uri.parse('https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lng&current=temperature_2m,weather_code');
  try {
    final res = await http.get(url).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final actual = data['current'] as Map<String, dynamic>;
    final temp = (actual['temperature_2m'] as num).toDouble();
    final codigo = (actual['weather_code'] as num).toInt();
    final (desc, emoji) = _interpretarCodigo(codigo);
    return Clima(temp, desc, emoji);
  } catch (_) {
    return null;
  }
}

/// Traduce el código de clima (estándar WMO) a texto y emoji en español.
(String, String) _interpretarCodigo(int codigo) {
  switch (codigo) {
    case 0:
      return (tr('Despejado', 'Clear'), '☀️');
    case 1:
      return (tr('Mayormente despejado', 'Mostly clear'), '🌤️');
    case 2:
      return (tr('Parcialmente nublado', 'Partly cloudy'), '⛅');
    case 3:
      return (tr('Nublado', 'Cloudy'), '☁️');
    case 45:
    case 48:
      return (tr('Neblina', 'Fog'), '🌫️');
    case 51:
    case 53:
    case 55:
      return (tr('Llovizna', 'Drizzle'), '🌦️');
    case 61:
    case 63:
    case 65:
      return (tr('Lluvia', 'Rain'), '🌧️');
    case 80:
    case 81:
    case 82:
      return (tr('Chubascos', 'Showers'), '🌦️');
    case 95:
    case 96:
    case 99:
      return (tr('Tormenta', 'Storm'), '⛈️');
    default:
      return (tr('Tiempo variable', 'Variable'), '🌡️');
  }
}
