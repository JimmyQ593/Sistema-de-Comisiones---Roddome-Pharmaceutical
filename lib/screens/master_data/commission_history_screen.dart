import 'package:flutter/material.dart';
import '../../utilities/export_files/historico_file.dart';
import '../../utilities/db_operations/history_data.dart';
import '../../theme/custom_button.dart';

// Código para generar el archivo Excel cuando se presiona el botón "EXPORTAR ARCHIVO"
class CommissionHistoryScreen extends StatefulWidget {
  const CommissionHistoryScreen({super.key});

  @override
  CommissionHistoryScreenState createState() => CommissionHistoryScreenState();
}

class CommissionHistoryScreenState extends State<CommissionHistoryScreen> {
  late Future<List<String>> availableMonths;
  List<String> selectedMonths = [];

  @override
  void initState() {
    super.initState();
    availableMonths = DbHistoryOperations.getAvailableMonths();
  }

  @override
  Widget build(BuildContext context) {
    List<String> months = [
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

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'HISTÓRICO DE COMISIONES',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(0, 37.0, 0, 35),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg_commission_history.png'),
            fit: BoxFit.fitHeight,
            opacity: 0.75,
          ),
        ),
        child: Center(
          child: FutureBuilder<List<String>>(
            future: availableMonths,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No hay datos disponibles');
              } else {
                List<String> enabledMonths = [];
                for (String month in snapshot.data!) {
                  int index = months.indexOf(month);
                  if (index != -1) {
                    int enabledIndex = (index + 2) % months.length;
                    enabledMonths.add(months[enabledIndex]);
                  }
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Text(
                        'Seleccione el mes o meses en el que desee ver el histórico de comisiones:',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 4,
                        crossAxisSpacing: 40,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2,
                        padding:
                            const EdgeInsets.fromLTRB(260.0, 25.0, 260.0, 0.0),
                        children: months.map((month) {
                          bool isEnabled = enabledMonths.contains(month);
                          bool isSelected = selectedMonths.contains(month);
                          return ElevatedButton(
                            onPressed: isEnabled
                                ? () {
                                    setState(() {
                                      if (isSelected) {
                                        selectedMonths.remove(month);
                                      } else {
                                        selectedMonths.add(month);
                                      }
                                    });
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected ? Colors.red : null,
                              disabledBackgroundColor:
                                  isSelected ? Colors.red[200] : null,
                            ),
                            child: Text(month),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    if (selectedMonths.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      CustomFloatingBtn(
                        label: 'EXPORTAR ARCHIVO',
                        icon: Icons.download_done_outlined,
                        onPressed: () async {
                          await HistoricoFileExporter()
                              .generateExcel(selectedMonths);
                          // ignore: use_build_context_synchronously
                          Navigator.pop(
                              context); // Vuelve a la pantalla anterior
                        },
                      ),
                    ],
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
