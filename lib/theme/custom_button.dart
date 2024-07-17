// ignore: file_names
import 'package:flutter/material.dart';

//buttons
class CustomFloatingBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final EdgeInsets? padding; //it can or can not have a padding

  //constructor
  const CustomFloatingBtn({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.padding, //default padding,
  });

  //here, the widget is built
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      icon: Icon(icon),
      foregroundColor: Colors.white,
      backgroundColor: const Color(0xFF424242), //grey[850], // Color de fondo
      extendedPadding: padding,
    );
  }
}