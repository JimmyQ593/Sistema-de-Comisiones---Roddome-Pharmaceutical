class Peso {
  int? id;
  int mercadoStId;
  String cargo;
  double valorPeso;

  Peso({
    this.id,
    required this.mercadoStId,
    required this.cargo,
    required this.valorPeso,
  });

  Map<String, dynamic> toMap() {
    return {
      'ID': id,
      'MERCADO_ST_ID': mercadoStId,
      'CARGO': cargo,
      'VALOR_PESO': valorPeso,
    };
  }

  factory Peso.fromMap(Map<String, dynamic> map) {
    return Peso(
      id: map['ID'],
      mercadoStId: map['MERCADO_ST_ID'],
      cargo: map['CARGO'],
      valorPeso: map['VALOR_PESO'],
    );
  }
}
