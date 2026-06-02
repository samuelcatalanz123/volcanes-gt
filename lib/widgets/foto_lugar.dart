import 'package:flutter/material.dart';

/// Muestra una foto desde internet, con esquinas redondeadas.
/// Mientras carga muestra un giro; si falla, muestra un ícono de respaldo.
class FotoLugar extends StatelessWidget {
  final String url;
  const FotoLugar({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        // Aparece suave cuando ya cargó (en vez de un indicador que en web
        // a veces se queda pegado).
        frameBuilder: (context, child, frame, wasSync) {
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            child: child,
          );
        },
        // Si la imagen no se puede cargar, muestra un respaldo.
        errorBuilder: (context, error, stack) => Container(
          height: 180,
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(Icons.image_not_supported,
                size: 48, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
