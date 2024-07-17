// ignore: depend_on_referenced_packages
import 'package:excel/excel.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:open_file/open_file.dart';
import '../../utilities/queries/historico_query.dart';

class HistoricoFileExporter {
  Future<void> generateExcel(List<String> selectedMonths) async {
    // Mapeo de meses con dos meses sumados
    Map<String, String> monthMap = {
      'ENERO': 'NOVIEMBRE',
      'FEBRERO': 'DICIEMBRE',
      'MARZO': 'ENERO',
      'ABRIL': 'FEBRERO',
      'MAYO': 'MARZO',
      'JUNIO': 'ABRIL',
      'JULIO': 'MAYO',
      'AGOSTO': 'JUNIO',
      'SEPTIEMBRE': 'JULIO',
      'OCTUBRE': 'AGOSTO',
      'NOVIEMBRE': 'SEPTIEMBRE',
      'DICIEMBRE': 'OCTUBRE'
    };

    // Genera la lista de meses originales a partir de los seleccionados
    List<String> originalMonths =
        selectedMonths.map((month) => monthMap[month]!).toList();

    // Realiza la consulta a la base de datos con los meses originales
    List<Map<String, dynamic>> results =
        await HistoricoQuery.getCommissionsByMonths(originalMonths);

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
      'ANIO',
      'MES',
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

    // Inserta los datos en la hoja "DETALLE COMISIONES"
    int rowIndex = 1;
    for (var row in results) {
      double valorObjetivo = row['MKS_OBJETIVO'];
      double valorReal = row['MKS_REAL'];
      double comisionCompleta = row['COLABORADOR_COMISION_COMPLETA'];
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

      sheetObject.insertRowIterables(
        [
          row['COLABORADOR_CI'],
          row['COLABORADOR_NOMBRE_COMPLETO'],
          row['COLABORADOR_CARGO'],
          row['COLABORADOR_JEFE_INMEDIATO'],
          row['ST'],
          row['MERCADO'],
          row['ANIO_COMISION'],
          row['MES_COMISION'],
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

    Directory? downloadsDirectory = await getDownloadsDirectory();
    String outputPath =
        join(downloadsDirectory!.path, 'HISTORICO-COMISIONES.xlsx');
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
}
