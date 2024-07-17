import 'package:flutter/material.dart';
import './commission/main_commission_screen.dart';
import './master_data/main_master_data_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late List<GlobalKey<NavigatorState>> _navigatorKeys;

  @override
  void initState() {
    super.initState();
    _navigatorKeys = List.generate(2, (index) => GlobalKey<NavigatorState>());
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      // Si el usuario toca el ítem seleccionado nuevamente, se restablece el estado inicial
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      // Resetear la navegación de ambos Navigator
      _navigatorKeys[_selectedIndex]
          .currentState
          ?.popUntil((route) => route.isFirst);
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);

      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _buildOffstageNavigator(
      int index, Widget child, GlobalKey<NavigatorState> navigatorKey) {
    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: navigatorKey,
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildOffstageNavigator(
              0, const CommissionScreen(), _navigatorKeys[0]),
          _buildOffstageNavigator(
              1, const MasterDataScreen(), _navigatorKeys[1]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'COMISIONES',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storage_rounded),
            label: 'DATA MAESTRA',
          ),
        ],
        iconSize: 60,
        selectedItemColor: Colors.red,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
