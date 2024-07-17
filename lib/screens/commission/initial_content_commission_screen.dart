import 'package:flutter/material.dart';
import '../../theme/custom_button.dart';
import '../../utilities/file_picker/file_picker_handler.dart';

class InitialContentCommissionScreen extends StatelessWidget {
  const InitialContentCommissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final filePickerHandler = FilePickerHandler();

    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                0, 0, 295, 50), // Ajusta el padding según sea necesario
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomFloatingBtn(
                  label: "ASTERS",
                  icon: Icons.wc,
                  onPressed: () {
                    filePickerHandler.pickFile(context);
                  },
                  padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                ),
                const SizedBox(height: 25),
                CustomFloatingBtn(
                  label: "GER. DE PRODUCTO",
                  icon: Icons.medication,
                  onPressed: () {
                    // Lógica para GERENTE DE PRODUCTO
                  },
                  padding: const EdgeInsets.all(10.0),
                ),
                const SizedBox(height: 25),
                CustomFloatingBtn(
                  label: "GER. PROMOCIÓN",
                  icon: Icons.co_present,
                  onPressed: () {
                    // Lógica para GERENTE PROMOCIÓN
                  },
                  padding: const EdgeInsets.all(10.0),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

