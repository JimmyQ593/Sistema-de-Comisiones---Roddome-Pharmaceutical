import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:file_picker/file_picker.dart';
import '../db_operations/load_data.dart';
import '../../utilities/export_files/aster_file.dart';

class FilePickerHandler {
  Future<void> pickFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xlsm'],
      );
      if (result != null) {
        String? filePath = result.files.single.path;
        if (filePath != null) {
          final loader = LoadExcelData();
          await loader.loadExcelData(filePath);
          final exporter = AsterFileExporter();
          await exporter.generateExcel();
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Comisiones calculadas y documento almacenado en su carpeta de Descargas')),
          );
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'El archivo seleccionado no cumple con la estructura necesaria')),
          );
        }
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
        ),
      );
    }
  }
}