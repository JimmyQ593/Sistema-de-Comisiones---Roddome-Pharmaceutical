import 'package:flutter/material.dart';
import '../../theme/custom_button.dart';
import '../../screens/master_data/commission_history_screen.dart';

import '../../utilities/db_operations/history_data.dart';

class InitialContentDataScreen extends StatelessWidget {
  const InitialContentDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            400, 0, 0, 200), // Ajusta el padding según sea necesario
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CustomFloatingBtn(
              label: 'HISTÓRICO DE COMISIONES',
              icon: Icons.calendar_month_outlined,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CommissionHistoryScreen(),
                ),
              ),
            ),
            const SizedBox(height: 25),
            CustomFloatingBtn(
              label: 'RESTAURAR HISTÓRICO',
              icon: Icons.delete_forever_rounded,
              onPressed: () =>
                  DbHistoryOperations.confirmClearHistorico(context),
            ),
          ],
        ),
      ),
    );
  }
}
