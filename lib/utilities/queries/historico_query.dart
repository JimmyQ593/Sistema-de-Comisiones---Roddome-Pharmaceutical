import '../../database/db_helper.dart';
class HistoricoQuery {
  static Future<List<Map<String, dynamic>>> getCommissionsByMonths(List<String> months) async {
    final db = await DbHelper().database;
    String placeholders = months.map((month) => '?').join(',');

    // Construye la consulta SQL
    String query = '''
      SELECT *
      FROM HISTORICO
      WHERE MES_COMISION IN ($placeholders)
    ''';

    return await db.rawQuery(query, months);
  }
}
