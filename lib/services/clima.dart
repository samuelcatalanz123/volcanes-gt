import 'dart:convert';
import 'package:http/http.dart' as http;

/// El clima actual de un lugar: temperatura y una descripción con emoji.
class Clima {
  final double tempC;
  final String descripcion;
  final String emoji;
  const Clima(this.tempC, this.descripcion, this.emoji);
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
      return ('Despejado', '☀️');
    case 1:
      return ('Mayormente despejado', '🌤️');
    case 2:
      return ('Parcialmente nublado', '⛅');
    case 3:
      return ('Nublado', '☁️');
    case 45:
    case 48:
      return ('Neblina', '🌫️');
    case 51:
    case 53:
    case 55:
      return ('Llovizna', '🌦️');
    case 61:
    case 63:
    case 65:
      return ('Lluvia', '🌧️');
    case 80:
    case 81:
    case 82:
      return ('Chubascos', '🌦️');
    case 95:
    case 96:
    case 99:
      return ('Tormenta', '⛈️');
    default:
      return ('Tiempo variable', '🌡️');
  }
}
