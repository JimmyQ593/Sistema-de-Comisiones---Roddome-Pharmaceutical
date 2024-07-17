class Historico {
  int? id;
  String colaboradorCi;
  String colaboradorNombreCompleto;
  String colaboradorCargo;
  String colaboradorJefeInmediato;
  double colaboradorComisionCompleta;
  String st;
  String mercado;
  int anioComision;
  String mesObjetivo;
  double mksObjetivo;
  double mksReal;
  double valorPeso;
  String uniqueKey;  // Nuevo campo

  Historico({
    this.id,
    required this.colaboradorCi,
    required this.colaboradorNombreCompleto,
    required this.colaboradorCargo,
    required this.colaboradorJefeInmediato,
    required this.colaboradorComisionCompleta,
    required this.st,
    required this.mercado,
    required this.anioComision,
    required this.mesObjetivo,
    required this.mksObjetivo,
    required this.mksReal,
    required this.valorPeso,
  }) : uniqueKey = '';

  void generateUniqueKey() {
    uniqueKey = '$colaboradorCi$colaboradorNombreCompleto$colaboradorCargo$colaboradorJefeInmediato$colaboradorComisionCompleta$st$mercado$anioComision$mesObjetivo$mksObjetivo$mksReal$valorPeso';
  }

  Map<String, dynamic> toMap() {
    return {
      'ID': id,
      'COLABORADOR_CI': colaboradorCi,
      'COLABORADOR_NOMBRE_COMPLETO': colaboradorNombreCompleto,
      'COLABORADOR_CARGO': colaboradorCargo,
      'COLABORADOR_JEFE_INMEDIATO': colaboradorJefeInmediato,
      'COLABORADOR_COMISION_COMPLETA': colaboradorComisionCompleta,
      'ST': st,
      'MERCADO': mercado,
      'ANIO_COMISION': anioComision,
      'MES_COMISION': mesObjetivo,
      'MKS_OBJETIVO': mksObjetivo,
      'MKS_REAL': mksReal,
      'VALOR_PESO': valorPeso,
      'UNIQUE_KEY': uniqueKey
    };
  }
}