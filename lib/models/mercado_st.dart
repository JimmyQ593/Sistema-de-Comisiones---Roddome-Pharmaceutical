class MercadoSt {
  int? id;
  String st;
  String mercado;

  MercadoSt({
    this.id,
    required this.st,
    required this.mercado,
  });

  Map<String, dynamic> toMap() {
    return {
      'ID': id,
      'ST': st,
      'MERCADO': mercado,
    };
  }

  factory MercadoSt.fromMap(Map<String, dynamic> map) {
    return MercadoSt(
      id: map['ID'],
      st: map['ST'],
      mercado: map['MERCADO'],
    );
  }
}