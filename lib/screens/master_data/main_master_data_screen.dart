import 'package:flutter/material.dart';
import 'package:sistema_comisiones_roddome/screens/master_data/initial_content_data_screen.dart';

class MasterDataScreen extends StatelessWidget {
  const MasterDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50.0,
        title: const Center(
          child: Text(
            'DATA MAESTRA',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/bg_master_data.png'), // Asegúrate de que la ruta sea correcta
            fit: BoxFit.cover,
            opacity: 0.75,
          ),
        ),
        child: const InitialContentDataScreen(),
      ),
    );
  }
}
