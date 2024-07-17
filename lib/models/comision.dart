class Comision {
  int? id;
  int colaboradorId;
  int pesoId;
  int mksObjetivoId;
  int mksRealId;

  Comision({
    this.id,
    required this.colaboradorId,
    required this.pesoId,
    required this.mksObjetivoId,
    required this.mksRealId,
  });

  Map<String, dynamic> toMap() {
    return {
      'ID': id,
      'COLABORADOR_ID': colaboradorId,
      'PESO_ID': pesoId,
      'MKS_OBJETIVO_ID': mksObjetivoId,
      'MKS_REAL_ID': mksRealId,
    };
  }
}
