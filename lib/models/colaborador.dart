class Colaborador {
  int? id;
  String ci;
  String nombreCompleto;
  String cargo;
  String jefeInmedato;
  String categoria;
  double comisionCompleta;

  Colaborador({
    this.id,
    required this.ci,
    required this.nombreCompleto,
    required this.cargo,
    required this.jefeInmedato,
    required this.categoria,
    required this.comisionCompleta,
  });

  Map<String, dynamic> toMap() {
    return {
      'ID': id,
      'CI': ci,
      'NOMBRE_COMPLETO': nombreCompleto,
      'CARGO': cargo,
      'JEFE_INMEDIATO': jefeInmedato,
      'CATEGORIA': categoria,
      'COMISION_COMPLETA': comisionCompleta,
    };
  }

  factory Colaborador.fromMap(Map<String, dynamic> map) {
    return Colaborador(
      id: map['ID'],
      ci: map['CI'],
      nombreCompleto: map['NOMBRE_COMPLETO'],
      cargo: map['CARGO'],
      jefeInmedato: map['JEFE_INMEDIATO'],
      categoria: map['CATEGORIA'],
      comisionCompleta: map['COMISION_COMPLETA'],
    );
  }
}
