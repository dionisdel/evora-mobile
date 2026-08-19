/// Modelo de farmacia (peticiones_visibilidad).
enum EstadoCuestionario { pendiente, enCurso, completado }

class Farmacia {
  final int id;
  final String externalId;
  final String nombre;
  final String direccion;
  final String poblacion;
  final String provincia;
  final String codigoPostal;
  final String? telefono;
  final EstadoCuestionario estadoCuestionario;
  final bool tienePostIt;
  final double? distanciaKm;

  const Farmacia({
    required this.id,
    required this.externalId,
    required this.nombre,
    required this.direccion,
    required this.poblacion,
    required this.provincia,
    required this.codigoPostal,
    this.telefono,
    required this.estadoCuestionario,
    required this.tienePostIt,
    this.distanciaKm,
  });

  factory Farmacia.fromJson(Map<String, dynamic> json) {
    return Farmacia(
      id: json['id'] as int,
      externalId: json['external_id'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      direccion: json['direccion'] as String? ?? '',
      poblacion: json['poblacion'] as String? ?? '',
      provincia: json['provincia'] as String? ?? '',
      codigoPostal: json['codigo_postal'] as String? ?? '',
      telefono: json['telefono'] as String?,
      estadoCuestionario: _parseEstado(json['estado_cuestionario'] as String?),
      tienePostIt: json['tiene_post_it'] as bool? ?? false,
      distanciaKm: (json['distancia_km'] as num?)?.toDouble(),
    );
  }

  String get direccionCompleta {
    return [direccion, poblacion, provincia]
        .where((s) => s.isNotEmpty)
        .join(', ');
  }
}

class FarmaciaDetalle extends Farmacia {
  final String? correo;
  final String? personaContacto;
  final String? tipoSolicitud;
  final String? opcion;
  final String? status;
  final PostIt? postIt;
  final int? fichaId;
  final Calendario? calendario;

  const FarmaciaDetalle({
    required super.id,
    required super.externalId,
    required super.nombre,
    required super.direccion,
    required super.poblacion,
    required super.provincia,
    required super.codigoPostal,
    super.telefono,
    required super.estadoCuestionario,
    required super.tienePostIt,
    super.distanciaKm,
    this.correo,
    this.personaContacto,
    this.tipoSolicitud,
    this.opcion,
    this.status,
    this.postIt,
    this.fichaId,
    this.calendario,
  });

  factory FarmaciaDetalle.fromJson(Map<String, dynamic> json) {
    return FarmaciaDetalle(
      id: json['id'] as int,
      externalId: json['external_id'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      direccion: json['direccion'] as String? ?? '',
      poblacion: json['poblacion'] as String? ?? '',
      provincia: json['provincia'] as String? ?? '',
      codigoPostal: json['codigo_postal'] as String? ?? '',
      telefono: json['telefono'] as String?,
      estadoCuestionario: _parseEstado(json['estado_cuestionario'] as String?),
      tienePostIt: json['tiene_post_it'] as bool? ?? false,
      distanciaKm: (json['distancia_km'] as num?)?.toDouble(),
      correo: json['correo'] as String?,
      personaContacto: json['persona_contacto'] as String?,
      tipoSolicitud: json['tipo_solicitud'] as String?,
      opcion: json['opcion'] as String?,
      status: json['status'] as String?,
      postIt: json['post_it'] != null
          ? PostIt.fromJson(json['post_it'] as Map<String, dynamic>)
          : null,
      fichaId: json['ficha_id'] as int?,
      calendario: json['calendario'] != null
          ? Calendario.fromJson(json['calendario'] as Map<String, dynamic>)
          : null,
    );
  }
}

EstadoCuestionario _parseEstado(String? estado) {
  switch (estado) {
    case 'en_curso':
      return EstadoCuestionario.enCurso;
    case 'completado':
      return EstadoCuestionario.completado;
    default:
      return EstadoCuestionario.pendiente;
  }
}

/// Post-It: campos de notas de peticiones_visibilidad.
class PostIt {
  final String? observaciones;
  final String? aLaAtencionDe;
  final String? marca;
  final String? campana;
  final String? opcionesAcordar;
  final String? direccionEnvio;
  final String? muestras;
  final String? otros;

  const PostIt({
    this.observaciones,
    this.aLaAtencionDe,
    this.marca,
    this.campana,
    this.opcionesAcordar,
    this.direccionEnvio,
    this.muestras,
    this.otros,
  });

  factory PostIt.fromJson(Map<String, dynamic> json) {
    return PostIt(
      observaciones: json['observaciones'] as String?,
      aLaAtencionDe: json['a_la_atencion_de'] as String?,
      marca: json['marca'] as String?,
      campana: json['campana'] as String?,
      opcionesAcordar: json['opciones_acordar'] as String?,
      direccionEnvio: json['direccion_envio'] as String?,
      muestras: json['muestras'] as String?,
      otros: json['otros'] as String?,
    );
  }

  /// Devuelve los campos con valor como pares label/valor.
  Map<String, String> get filledFields {
    final map = <String, String>{};
    if (observaciones?.isNotEmpty == true) map['Observaciones'] = observaciones!;
    if (aLaAtencionDe?.isNotEmpty == true) {
      map['A la atención de'] = aLaAtencionDe!;
    }
    if (marca?.isNotEmpty == true) map['Marca'] = marca!;
    if (campana?.isNotEmpty == true) map['Campaña'] = campana!;
    if (opcionesAcordar?.isNotEmpty == true) {
      map['Opciones a acordar'] = opcionesAcordar!;
    }
    if (direccionEnvio?.isNotEmpty == true) {
      map['Dirección de envío'] = direccionEnvio!;
    }
    if (muestras?.isNotEmpty == true) map['Muestras'] = muestras!;
    if (otros?.isNotEmpty == true) map['Otros'] = otros!;
    return map;
  }
}

/// Calendario de visita (peticiones_calendario).
class Calendario {
  final String? fechaAgendada;
  final String? horaVisita;
  final String? fechaRealizada;
  final String tipoVisita;

  const Calendario({
    this.fechaAgendada,
    this.horaVisita,
    this.fechaRealizada,
    required this.tipoVisita,
  });

  factory Calendario.fromJson(Map<String, dynamic> json) {
    return Calendario(
      fechaAgendada: json['fecha_agendada'] as String?,
      horaVisita: json['hora_visita'] as String?,
      fechaRealizada: json['fecha_realizada'] as String?,
      tipoVisita: json['tipo_visita'] as String? ?? 'Normal',
    );
  }
}
