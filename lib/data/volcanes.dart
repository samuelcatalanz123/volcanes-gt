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
