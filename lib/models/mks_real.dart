class MksReal {
  int? id;
  int colaboradorId;
  int mercadoStId;
  int anio;
  String mes;
  double valorReal;

  MksReal({
    this.id,
    required this.colaboradorId,
    required this.mercadoStId,
    required this.anio,
    required this.mes,
    required this.valorReal,
  });

  Map<String, dynamic> toMap() {
    return {
      'ID': id,
      'COLABORADOR_ID': colaboradorId,
      'MERCADO_ST_ID': mercadoStId,
      'ANIO': anio,
      'MES': mes,
      'VALOR_REAL': valorReal,
    };
  }

  factory MksReal.fromMap(Map<String, dynamic> map) {
    return MksReal(
      id: map['ID'],
      colaboradorId: map['COLABORADOR_ID'],
      mercadoStId: map['MERCADO_ST_ID'],
      anio: map['ANIO'],
      mes: map['MES'],
      valorReal: map['VALOR_REAL'],
    );
  }
}
