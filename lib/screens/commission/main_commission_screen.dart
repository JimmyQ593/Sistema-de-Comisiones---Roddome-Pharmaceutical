import 'package:flutter/material.dart';
import 'package:sistema_comisiones_roddome/screens/commission/initial_content_commission_screen.dart';

class CommissionScreen extends StatelessWidget {
  const CommissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50.0,
        title: const Center(
          child: Text(
            'COMISIONES',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/bg_commission.png'), // Asegúrate de que la ruta sea correcta
            fit: BoxFit.cover,
            opacity: 0.75,
          ),
        ),
        child: const InitialContentCommissionScreen(),
      ),
    );
  }
}
