import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import './app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized;
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const MyApp());
}
