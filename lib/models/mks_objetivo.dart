class MksObjetivo {
  int? id;
  int colaboradorId;
  int mercadoStId;
  int anio;
  String mes;
  double valorObjetivo;

  MksObjetivo({
    this.id,
    required this.colaboradorId,
    required this.mercadoStId,
    required this.anio,
    required this.mes,
    required this.valorObjetivo,
  });

  Map<String, dynamic> toMap() {
    return {
      'ID': id,
      'COLABORADOR_ID': colaboradorId,
      'MERCADO_ST_ID': mercadoStId,
      'ANIO': anio,
      'MES': mes,
      'VALOR_OBJETIVO': valorObjetivo,
    };
  }

  factory MksObjetivo.fromMap(Map<String, dynamic> map) {
    return MksObjetivo(
      id: map['ID'],
      colaboradorId: map['COLABORADOR_ID'],
      mercadoStId: map['MERCADO_ST_ID'],
      anio: map['ANIO'],
      mes: map['MES'],
      valorObjetivo: map['VALOR_OBJETIVO'],
    );
  }
}
