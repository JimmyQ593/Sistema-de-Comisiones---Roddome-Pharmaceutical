import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
// ignore: depend_on_referenced_packages
import 'package:sqflite/sqflite.dart';
import '../models/colaborador.dart';
import '../models/mercado_st.dart';
import '../models/mks_objetivo.dart';
import '../models/mks_real.dart';
import '../models/peso.dart';
import '../models/comision.dart';
import '../models/historico.dart';

class DbHelper {
  DbHelper._internal();

  static final DbHelper _instance = DbHelper._internal();

  factory DbHelper() => _instance;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    Directory appDirectory = Directory.current;
    String path = join(appDirectory.path, 'local_database', 'DB_COMISIONES.db');
    await Directory(dirname(path)).create(recursive: true);

    return await openDatabase(path,
        version: 3, // Aumentamos la versión de la base de datos
        onCreate: (Database db, int version) async {
      // Crear las tablas aquí
      await db.execute('''
          CREATE TABLE COLABORADOR (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            CI TEXT UNIQUE NOT NULL,
            NOMBRE_COMPLETO TEXT NOT NULL,
            CARGO TEXT NOT NULL,
            JEFE_INMEDIATO TEXT NOT NULL,
            CATEGORIA TEXT NOT NULL,
            COMISION_COMPLETA FLOAT
          )
        ''');

      await db.execute('''
          CREATE TABLE MERCADO_ST (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            ST TEXT NOT NULL,
            MERCADO TEXT NOT NULL,
            UNIQUE(ST, MERCADO)
          )
        ''');

      await db.execute('''
          CREATE TABLE MKS_OBJETIVO (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            COLABORADOR_ID INTEGER NOT NULL,
            MERCADO_ST_ID INTEGER NOT NULL,
            ANIO INTEGER NOT NULL,
            MES TEXT NOT NULL,
            VALOR_OBJETIVO FLOAT NOT NULL,
            FOREIGN KEY (COLABORADOR_ID) REFERENCES COLABORADOR(ID),
            FOREIGN KEY (MERCADO_ST_ID) REFERENCES MERCADO_ST(ID)
          )
        ''');

      await db.execute('''
          CREATE TABLE MKS_REAL (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            COLABORADOR_ID INTEGER NOT NULL,
            MERCADO_ST_ID INTEGER NOT NULL,
            ANIO INTEGER NOT NULL,
            MES TEXT NOT NULL,
            VALOR_REAL FLOAT NOT NULL,
            FOREIGN KEY (COLABORADOR_ID) REFERENCES COLABORADOR(ID),
            FOREIGN KEY (MERCADO_ST_ID) REFERENCES MERCADO_ST(ID)
          )
        ''');

      await db.execute('''
          CREATE TABLE PESO (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            MERCADO_ST_ID INTEGER NOT NULL,
            CARGO TEXT NOT NULL,
            VALOR_PESO FLOAT NOT NULL,
            FOREIGN KEY (MERCADO_ST_ID) REFERENCES MERCADO_ST(ID)
          )
        ''');

      await db.execute('''
          CREATE TABLE COMISION (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            COLABORADOR_ID INTEGER NOT NULL,
            PESO_ID INTEGER NOT NULL,
            MKS_OBJETIVO_ID INTEGER NOT NULL,
            MKS_REAL_ID INTEGER NOT NULL,
            FOREIGN KEY (COLABORADOR_ID) REFERENCES COLABORADOR(ID),
            FOREIGN KEY (PESO_ID) REFERENCES PESO(ID),
            FOREIGN KEY (MKS_OBJETIVO_ID) REFERENCES MKS_OBJETIVO(ID),
            FOREIGN KEY (MKS_REAL_ID) REFERENCES MKS_REAL(ID)
          )
        ''');

      // Crear la tabla HISTORICO con el campo UNIQUE_KEY
      await db.execute('''
          CREATE TABLE HISTORICO (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            COLABORADOR_CI TEXT NOT NULL,
            COLABORADOR_NOMBRE_COMPLETO TEXT NOT NULL,
            COLABORADOR_CARGO TEXT NOT NULL,
            COLABORADOR_JEFE_INMEDIATO TEXT NOT NULL,
            COLABORADOR_COMISION_COMPLETA FLOAT,
            ST TEXT NOT NULL,
            MERCADO TEXT NOT NULL,
            ANIO_COMISION INTEGER NOT NULL,
            MES_COMISION TEXT NOT NULL,
            MKS_OBJETIVO FLOAT NOT NULL,
            MKS_REAL FLOAT NOT NULL,
            VALOR_PESO FLOAT NOT NULL,
            UNIQUE_KEY TEXT UNIQUE NOT NULL
          )
        ''');
    }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
      if (oldVersion < 3) {
        await db.execute('DROP TABLE IF EXISTS HISTORICO');
        await db.execute('''
            CREATE TABLE HISTORICO (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            COLABORADOR_CI TEXT NOT NULL,
            COLABORADOR_NOMBRE_COMPLETO TEXT NOT NULL,
            COLABORADOR_CARGO TEXT NOT NULL,
            COLABORADOR_JEFE_INMEDIATO TEXT NOT NULL,
            COLABORADOR_COMISION_COMPLETA FLOAT,
            ST TEXT NOT NULL,
            MERCADO TEXT NOT NULL,
            ANIO_COMISION INTEGER NOT NULL,
            MES_COMISION TEXT NOT NULL,
            MKS_OBJETIVO FLOAT NOT NULL,
            MKS_REAL FLOAT NOT NULL,
            VALOR_PESO FLOAT NOT NULL,
            UNIQUE_KEY TEXT UNIQUE NOT NULL
            )
          ''');
      }
    });
  }

  // Métodos de inserción para cada tabla
  Future<int> insertColaborador(Colaborador colaborador) async {
    final db = await database;
    return await db.insert('COLABORADOR', colaborador.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertMercadoSt(MercadoSt mercadoSt) async {
    final db = await database;
    return await db.insert('MERCADO_ST', mercadoSt.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertMksObjetivo(MksObjetivo mksObjetivo) async {
    final db = await database;
    return await db.insert('MKS_OBJETIVO', mksObjetivo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertMksReal(MksReal mksReal) async {
    final db = await database;
    return await db.insert('MKS_REAL', mksReal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertPeso(Peso peso) async {
    final db = await database;
    return await db.insert('PESO', peso.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertComision(Comision comision) async {
    final db = await database;
    return await db.insert('COMISION', comision.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertHistorico(Historico historico) async {
    final db = await database;
    return await db.insert('HISTORICO', historico.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);  // Usar ignore para evitar duplicados
  }

  Future<List<Map<String, dynamic>>> executeQuery(String query) async {
    final db = await database;
    return await db.rawQuery(query);
  }

  // Método para limpiar la tabla HISTORICO
  Future<void> clearHistorico() async {
    final db = await database;
    await db.delete('HISTORICO');
  }
}