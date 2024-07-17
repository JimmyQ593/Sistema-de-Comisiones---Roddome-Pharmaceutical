import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:excel/excel.dart';
// ignore: depend_on_referenced_packages
import 'package:sqflite/sqflite.dart';
import '../../database/db_helper.dart';
import '../../models/colaborador.dart';
import '../../models/mercado_st.dart';
import '../../models/mks_objetivo.dart';
import '../../models/mks_real.dart';
import '../../models/peso.dart';
import '../../models/comision.dart';
import '../../models/historico.dart';

class LoadExcelData {
  Future<void> loadExcelData(String filePath) async {
    var bytes = File(filePath).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    final dbHelper = DbHelper();
    final db = await dbHelper.database;

    await db.transaction((txn) async {
      await _clearDatabase(txn);
      await _loadColaboradores(txn, excel['COLABORADOR']);
      await _loadPesoYMercadoSt(txn, excel['PESO']);
      await _loadMksObjetivo(txn, excel['MKS_OBJ']);
      await _loadMksReal(txn, excel['MKS_REAL']);
      await _generateHistorico(txn);
      await _generateComisiones(txn);
    });
  }

  Future<void> _clearDatabase(Transaction txn) async {
    const tables = [
      'MKS_REAL',
      'MKS_OBJETIVO',
      'PESO',
      'MERCADO_ST',
      'COLABORADOR',
      'COMISION'
    ];
    for (var table in tables) {
      await txn.delete(table);
    }
  }

  Future<void> _loadColaboradores(Transaction txn, Sheet sheet) async {
    for (var row in sheet.rows.skip(1)) {
      if (row.length < 6) continue;

      var colaborador = Colaborador(
        ci: row[0]?.value?.toString() ?? '',
        nombreCompleto: row[1]?.value?.toString() ?? '',
        cargo: row[2]?.value?.toString() ?? '',
        jefeInmedato: row[3]?.value?.toString() ?? '',
        categoria: row[4]?.value?.toString() ?? '',
        comisionCompleta:
            double.tryParse(row[5]?.value?.toString() ?? '0') ?? 0.0,
      );
      await txn.insert('COLABORADOR', colaborador.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> _loadPesoYMercadoSt(Transaction txn, Sheet sheet) async {
    for (var row in sheet.rows.skip(1)) {
      if (row.length < 4) continue;

      var mercadoSt = MercadoSt(
        st: row[0]?.value?.toString() ?? '',
        mercado: row[1]?.value?.toString() ?? '',
      );
      int mercadoStId = await txn.insert('MERCADO_ST', mercadoSt.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);

      var peso = Peso(
        mercadoStId: mercadoStId,
        cargo: row[2]?.value?.toString() ?? '',
        valorPeso: double.tryParse(row[3]?.value?.toString() ?? '0') ?? 0.0,
      );
      await txn.insert('PESO', peso.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> _loadMksObjetivo(Transaction txn, Sheet sheet) async {
    for (var row in sheet.rows.skip(1)) {
      if (row.length < 6) continue;

      String ci = row[0]?.value?.toString() ?? '';
      var colaborador = await txn.query(
        'COLABORADOR',
        where: 'CI = ?',
        whereArgs: [ci],
      );
      if (colaborador.isEmpty) continue;
      int colaboradorId = colaborador.first['ID'] as int;

      String st = row[1]?.value?.toString() ?? '';
      String mercado = row[2]?.value?.toString() ?? '';
      var mercadoSt = await txn.query(
        'MERCADO_ST',
        where: 'ST = ? AND MERCADO = ?',
        whereArgs: [st, mercado],
      );
      if (mercadoSt.isEmpty) continue;
      int mercadoStId = mercadoSt.first['ID'] as int;

      var mksObjetivo = MksObjetivo(
        colaboradorId: colaboradorId,
        mercadoStId: mercadoStId,
        anio: int.tryParse(row[3]?.value?.toString() ?? '0') ?? 0,
        mes: row[4]?.value?.toString() ?? '',
        valorObjetivo: double.tryParse(row[5]?.value?.toString() ?? '0') ?? 0.0,
      );
      await txn.insert('MKS_OBJETIVO', mksObjetivo.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> _loadMksReal(Transaction txn, Sheet sheet) async {
    for (var row in sheet.rows.skip(1)) {
      if (row.length < 6) continue;

      String ci = row[0]?.value?.toString() ?? '';
      var colaborador = await txn.query(
        'COLABORADOR',
        where: 'CI = ?',
        whereArgs: [ci],
      );
      if (colaborador.isEmpty) continue;
      int colaboradorId = colaborador.first['ID'] as int;

      String st = row[1]?.value?.toString() ?? '';
      String mercado = row[2]?.value?.toString() ?? '';
      var mercadoSt = await txn.query(
        'MERCADO_ST',
        where: 'ST = ? AND MERCADO = ?',
        whereArgs: [st, mercado],
      );
      if (mercadoSt.isEmpty) continue;
      int mercadoStId = mercadoSt.first['ID'] as int;

      var mksReal = MksReal(
        colaboradorId: colaboradorId,
        mercadoStId: mercadoStId,
        anio: int.tryParse(row[3]?.value?.toString() ?? '0') ?? 0,
        mes: row[4]?.value?.toString() ?? '',
        valorReal: double.tryParse(row[5]?.value?.toString() ?? '0') ?? 0.0,
      );
      await txn.insert('MKS_REAL', mksReal.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> _generateComisiones(Transaction txn) async {
    var mksObjetivos = await txn.query('MKS_OBJETIVO');
    var mksReales = await txn.query('MKS_REAL');
    var pesos = await txn.query('PESO');

    for (var objetivo in mksObjetivos) {
      var real = mksReales.firstWhere(
        (r) =>
            r['COLABORADOR_ID'] == objetivo['COLABORADOR_ID'] &&
            r['MERCADO_ST_ID'] == objetivo['MERCADO_ST_ID'] &&
            r['ANIO'] == objetivo['ANIO'] &&
            r['MES'] == objetivo['MES'],
        orElse: () => {},
      );
      if (real.isEmpty) continue;

      var peso = pesos.firstWhere(
        (p) => p['MERCADO_ST_ID'] == objetivo['MERCADO_ST_ID'],
        orElse: () => {},
      );
      if (peso.isEmpty) continue;

      var comision = Comision(
        colaboradorId: objetivo['COLABORADOR_ID'] as int,
        pesoId: peso['ID'] as int,
        mksObjetivoId: objetivo['ID'] as int,
        mksRealId: real['ID'] as int,
      );
      await txn.insert('COMISION', comision.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> _generateHistorico(Transaction txn) async {
    var mksObjetivos = await txn.query('MKS_OBJETIVO');
    var mksReales = await txn.query('MKS_REAL');
    var pesos = await txn.query('PESO');
    var colaboradores = await txn.query('COLABORADOR');
    var mercados = await txn.query('MERCADO_ST');

    for (var objetivo in mksObjetivos) {
      var real = mksReales.firstWhere(
        (r) =>
            r['COLABORADOR_ID'] == objetivo['COLABORADOR_ID'] &&
            r['MERCADO_ST_ID'] == objetivo['MERCADO_ST_ID'] &&
            r['ANIO'] == objetivo['ANIO'] &&
            r['MES'] == objetivo['MES'],
        orElse: () => {},
      );
      if (real.isEmpty) continue;

      var peso = pesos.firstWhere(
        (p) => p['MERCADO_ST_ID'] == objetivo['MERCADO_ST_ID'],
        orElse: () => {},
      );
      if (peso.isEmpty) continue;

      var colaborador = colaboradores.firstWhere(
        (c) => c['ID'] == objetivo['COLABORADOR_ID'],
        orElse: () => {},
      );
      if (colaborador.isEmpty) continue;

      var mercadoSt = mercados.firstWhere(
        (m) => m['ID'] == objetivo['MERCADO_ST_ID'],
        orElse: () => {},
      );
      if (mercadoSt.isEmpty) continue;

      var historico = Historico(
        colaboradorCi: colaborador['CI'] as String,
        colaboradorNombreCompleto: colaborador['NOMBRE_COMPLETO'] as String,
        colaboradorCargo: colaborador['CARGO'] as String,
        colaboradorJefeInmediato: colaborador['JEFE_INMEDIATO'] as String,
        colaboradorComisionCompleta: colaborador['COMISION_COMPLETA'] as double,
        st: mercadoSt['ST'] as String,
        mercado: mercadoSt['MERCADO'] as String,
        anioComision: objetivo['ANIO'] as int,
        mesObjetivo: objetivo['MES'] as String,
        mksObjetivo: objetivo['VALOR_OBJETIVO'] as double,
        mksReal: real['VALOR_REAL'] as double,
        valorPeso: peso['VALOR_PESO'] as double,
      );

      historico.generateUniqueKey();

      await txn.insert('HISTORICO', historico.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }
}
