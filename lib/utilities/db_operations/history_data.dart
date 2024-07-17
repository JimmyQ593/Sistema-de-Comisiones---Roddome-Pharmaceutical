import 'package:flutter/material.dart';
import '../../database/db_helper.dart'; // Asegúrate de importar DbHelper

class DbHistoryOperations {
  static Future<void> confirmClearHistorico(BuildContext context) async {
    final dbHelper = DbHelper();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Acción'),
          content: const Text(
              '¿Estás seguro de que deseas restaurar el histórico? \nEsta acción no se puede deshacer.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await dbHelper.clearHistorico();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Histórico restaurado correctamente.')),
      );
    }
  }

  static Future<List<String>> getAvailableMonths() async {
    final dbHelper = DbHelper();
    final db = await dbHelper.database;

    List<Map<String, dynamic>> results =
        await db.rawQuery('SELECT DISTINCT MES_COMISION FROM HISTORICO');

    return results.map((row) => row['MES_COMISION'] as String).toList();
  }
}
