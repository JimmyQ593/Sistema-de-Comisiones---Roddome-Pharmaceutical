import '../../database/db_helper.dart';

class AsterCommissionCalculator {
  final DbHelper _dbHelper = DbHelper();

  Future<List<Map<String, dynamic>>> getCommissions() async {
    final db = await _dbHelper.database;

    List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT 
        COLABORADOR.CI,
        COLABORADOR.NOMBRE_COMPLETO,
        COLABORADOR.CARGO,
        COLABORADOR.JEFE_INMEDIATO,
        MERCADO_ST.ST,
        MERCADO_ST.MERCADO,
        COLABORADOR.COMISION_COMPLETA,
        PESO.VALOR_PESO,
        MKS_OBJETIVO.VALOR_OBJETIVO,
        MKS_REAL.VALOR_REAL,
        MKS_OBJETIVO.MES
      FROM COMISION
      JOIN COLABORADOR ON COMISION.COLABORADOR_ID = COLABORADOR.ID
      JOIN PESO ON COMISION.PESO_ID = PESO.ID
      JOIN MKS_OBJETIVO ON COMISION.MKS_OBJETIVO_ID = MKS_OBJETIVO.ID
      JOIN MKS_REAL ON COMISION.MKS_REAL_ID = MKS_REAL.ID
      JOIN MERCADO_ST ON MKS_OBJETIVO.MERCADO_ST_ID = MERCADO_ST.ID
    ''');

    if (results.isEmpty) {
      //print('No se encontraron registros.');
      return [];
    }

    return results;
  }
}
