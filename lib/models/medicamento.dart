class Medicamento {
  final int? id;
  final String nombre;
  final String dosis;
  final int frecuenciaHoras;
  final int duracionDias;
  final bool esCritico;

  Medicamento({
    this.id,
    required this.nombre,
    required this.dosis,
    required this.frecuenciaHoras,
    required this.duracionDias,
    this.esCritico = false,
  });

  // Para convertir los datos que vienen de la base de datos (Supabase)
  factory Medicamento.fromJson(Map<String, dynamic> json) {
    return Medicamento(
      id: json['id_medicamento'],
      nombre: json['nombre'],
      dosis: json['dosis'],
      frecuenciaHoras: json['frecuencia_horas'],
      duracionDias: json['duracion_dias'],
      esCritico: json['es_critico'] == 1 || json['es_critico'] == true,
    );
  }
}