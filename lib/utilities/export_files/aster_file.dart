import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:excel/excel.dart';
// ignore: depend_on_referenced_packages
import 'package:open_file/open_file.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import '../queries/aster_query.dart';

class AsterFileExporter {
  final AsterCommissionCalculator _calculator = AsterCommissionCalculator();

  Future<void> generateExcel() async {
    // Crea la consulta con los campos necesarios
    List<Map<String, dynamic>> results = await _calculator.getCommissions();

    var excel = Excel.createExcel();
    String sheetName = 'DETALLE COMISIONES';
    Sheet sheetObject = excel[sheetName];

    // Agrega los encabezados de la hoja "DETALLE COMISIONES"
    List<String> headers = [
      'CI',
      'NOMBRES COMPLETOS',
      'CARGO',
      'JEFE INMEDIATO',
      'ST',
      'MERCADO',
      'COMISION 100%',
      'PESO',
      'PESO EN \$',
      'MKS OBJ',
      'MKS REAL',
      'CUMPLIMIENTO',
      'CUMPLIMIENTO TRUNCADO',
      'CUMPLIMIENTO FINAL',
      'PAGO SUBTOTAL'
    ];

    sheetObject.insertRowIterables(headers, 0);

    Map<String, double> pagosTotales = {};
    Map<String, double> comisionCompletaPorCI = {};

    String mes = results.first['MES'];
    String nextMonth = getNextMonth(mes, 2);

    // Clasifica los resultados por jefe inmediato
    Map<String, List<Map<String, dynamic>>> resultadosPorJefe = {};
    for (var row in results) {
      String jefe = row['JEFE_INMEDIATO'];
      if (!resultadosPorJefe.containsKey(jefe)) {
        resultadosPorJefe[jefe] = [];
      }
      resultadosPorJefe[jefe]!.add(row);
    }

    int rowIndex = 1;
    resultadosPorJefe.forEach((jefe, rows) {
      for (var row in rows) {
        double valorObjetivo = row['VALOR_OBJETIVO'];
        double valorReal = row['VALOR_REAL'];
        double comisionCompleta = row['COMISION_COMPLETA'];
        double peso = row['VALOR_PESO'];
        double pesoEnDolares = (comisionCompleta * peso) / 100;
        double cumplimiento = (valorReal * 100) / valorObjetivo;
        double aux = (cumplimiento * 100) / 100;
        int cumplimientoTruncado = aux.round();

        // % cumplimiento según las reglas del negocio
        int cumplimientoFinal;

        if (cumplimientoTruncado < 80) {
          cumplimientoFinal = 0;
        } else if (cumplimientoTruncado <= 100) {
          cumplimientoFinal = cumplimientoTruncado;
        } else if (cumplimientoTruncado <= 130) {
          cumplimientoFinal = 100 + 2 * (cumplimientoTruncado - 100);
        } else {
          cumplimientoFinal = 160;
        }

        double aux1 = (cumplimientoFinal * pesoEnDolares) / 100;
        double pagoSubtotal = aux1.roundToDouble();

        if (!pagosTotales.containsKey(row['CI'])) {
          pagosTotales[row['CI']] = 0.0;
          comisionCompletaPorCI[row['CI']] = comisionCompleta;
        }
        pagosTotales[row['CI']] = pagosTotales[row['CI']]! + pagoSubtotal;

        sheetObject.insertRowIterables(
          [
            row['CI'],
            row['NOMBRE_COMPLETO'],
            row['CARGO'],
            row['JEFE_INMEDIATO'],
            row['ST'],
            row['MERCADO'],
            comisionCompleta,
            peso,
            pesoEnDolares,
            valorObjetivo,
            valorReal,
            cumplimiento,
            cumplimientoTruncado,
            cumplimientoFinal,
            pagoSubtotal,
          ],
          rowIndex,
        );
        rowIndex++;
      }
    });

    String consolidatedSheetName = 'CONSOLIDADO';
    Sheet consolidatedSheet = excel[consolidatedSheetName];

    // Agrega los encabezados de la hoja "CONSOLIDADO"
    consolidatedSheet.insertRowIterables(
      [
        'CI',
        'NOMBRES COMPLETOS',
        'COMISION 100%',
        'PAGO FINAL',
        'CUMPLIMIENTO GENERAL'
      ],
      0,
    );

    pagosTotales.forEach((ci, pagoFinal) {
      double comisionCompleta = comisionCompletaPorCI[ci]!;
      double cumplimientoGeneral = (pagoFinal / comisionCompleta) * 100;

      consolidatedSheet.appendRow([
        ci,
        results.firstWhere((row) => row['CI'] == ci)['NOMBRE_COMPLETO'],
        comisionCompleta,
        pagoFinal.roundToDouble(),
        '${cumplimientoGeneral.toStringAsFixed(2)}%'
      ]);
    });

    // Agrega hojas para cada jefe inmediato
    resultadosPorJefe.forEach((jefe, rows) {
      Sheet jefeSheet = excel[jefe];
      jefeSheet.insertRowIterables(headers, 0);
      for (var i = 0; i < rows.length; i++) {
        var row = rows[i];
        double valorObjetivo = row['VALOR_OBJETIVO'];
        double valorReal = row['VALOR_REAL'];
        double comisionCompleta = row['COMISION_COMPLETA'];
        double peso = row['VALOR_PESO'];
        double pesoEnDolares = (comisionCompleta * peso) / 100;
        double cumplimiento = (valorReal * 100) / valorObjetivo;
        double aux = (cumplimiento * 100) / 100;
        int cumplimientoTruncado = aux.round();

        // % cumplimiento según las reglas del negocio
        int cumplimientoFinal;

        if (cumplimientoTruncado < 80) {
          cumplimientoFinal = 0;
        } else if (cumplimientoTruncado <= 100) {
          cumplimientoFinal = cumplimientoTruncado;
        } else if (cumplimientoTruncado <= 130) {
          cumplimientoFinal = 100 + 2 * (cumplimientoTruncado - 100);
        } else {
          cumplimientoFinal = 160;
        }

        double aux1 = (cumplimientoFinal * pesoEnDolares) / 100;
        double pagoSubtotal = aux1.roundToDouble();

        jefeSheet.insertRowIterables(
          [
            row['CI'],
            row['NOMBRE_COMPLETO'],
            row['CARGO'],
            row['JEFE_INMEDIATO'],
            row['ST'],
            row['MERCADO'],
            comisionCompleta,
            peso,
            pesoEnDolares,
            valorObjetivo,
            valorReal,
            cumplimiento,
            cumplimientoTruncado,
            cumplimientoFinal,
            pagoSubtotal,
          ],
          i + 1,
        );
      }
    });

    Directory? downloadsDirectory = await getDownloadsDirectory();
    String outputPath =
        join(downloadsDirectory!.path, 'COMISIONES-ASTER-$nextMonth.xlsx');
    var fileBytes = excel.save();
    File(outputPath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);

    await openExcel(outputPath);
  }

  Future<void> openExcel(String filePath) async {
    final result = await OpenFile.open(filePath);
    if (result.type != ResultType.done) {
      print('Error al abrir el archivo: ${result.message}');
    }
  }

  String getNextMonth(String currentMonth, int increment) {
    const monthNames = [
      'ENERO',
      'FEBRERO',
      'MARZO',
      'ABRIL',
      'MAYO',
      'JUNIO',
      'JULIO',
      'AGOSTO',
      'SEPTIEMBRE',
      'OCTUBRE',
      'NOVIEMBRE',
      'DICIEMBRE'
    ];
    int currentIndex = monthNames.indexOf(currentMonth.toUpperCase());
    int nextIndex = (currentIndex + increment) % 12;
    return monthNames[nextIndex];
  }
}
