import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:qrscanner/src/models/scan_model.dart';
export  'package:qrscanner/src/models/scan_model.dart';

class DBProvider{

  // Patron Singleton

  // Database viene de sqflite
  static Database _database;
  static final DBProvider db = DBProvider._();

  // Constructor privado
  DBProvider._();
  // Retorna la base de datos, ni no estaba creada, la crea y la retorna
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  initDB() async {
    // getApplicationDocumentsDirectory viene del path_provider, obtiene el directorio donde se guardan los documentos de la app
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    
    final path = join( documentsDirectory.path, 'ScansDB.db');

    // openDatabase viene de sqflite
    // Si ya existe retorna la db que ya esta creada sino, la crea
    return await openDatabase(
      path,
      version: 1,
      onOpen: (db){},
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE Scans ( id INTEGER PRIMARY KEY, tipo TEXT, valor TEXT)'
        );
      }
    );

  }

  // CREAR Registros
  // Crea un registro (con una raw query)
  nuevoScanRaw(ScanModel nuevoScan) async {
    // confirma que la db este lista para usar y la trae
    final db = await database;
    // OJO tipo y valor son strings hay que mandarlos como strings en la query
    final res = await db.rawInsert(
      "INSERT Into Scans (id, tipo, valor) VALUES ( ${ nuevoScan.id }, '${ nuevoScan.tipo }', '${ nuevoScan.valor }' )"
    );
    return res;
  }

  // Crea un registro usando el query builder (mas easy y seguro, requiere que el objeto tenga un metodo que lo convierta a un map)
  // (este metodo hace lo mismo que el de arriba xd)
  nuevoScan( ScanModel nuevoScan ) async {
    final db  = await database;
    final res = await db.insert('Scans', nuevoScan.toJson());
    return res;
  }

  // SELECT

  // Busca un scan por id y lo retorna
  Future<ScanModel> getScanbyId(int id) async {
    final db  = await database;
    // query retorna una lista de maps
    final res = await db.query('Scans', where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty ? ScanModel.fromJson(res.first): null;
  }
  // Retorna todos los scans
  Future<List<ScanModel>> getTodosScans() async{
    final db  = await database;
    final res = await db.query('Scans');
    List<ScanModel> list = res.isNotEmpty
                          ? res.map((c)=> ScanModel.fromJson(c)).toList()
                          : [];
    return list;
  }
  // Retorna todos los scans segun tipo
  Future<List<ScanModel>> getScansPorTipo( String tipo ) async{
    final db  = await database;
    final res = await db.rawQuery("SELECT * FROM Scans WHERE tipo ='$tipo'");
    
    List<ScanModel> list = res.isNotEmpty
                          ? res.map((c)=> ScanModel.fromJson(c)).toList()
                          : [];
    return list;
  }

  // UPDATE

  // Actualiza un registro
  Future<int> updateScan( ScanModel nuevoScan ) async{
    final db  = await database;
    final res = await db.update('Scans', nuevoScan.toJson(), where: 'id = ?', whereArgs: [nuevoScan.id]);
    return res;
  }

  // DELETE

  // Borra un registro
  Future<int> deleteScan( int id ) async{
    final db  = await database;
    final res = await db.delete('Scans', where: 'id = ?', whereArgs: [id]);
    return res;
  }
  
  // Borra un registro
  Future<int> deleteAll() async{
    final db  = await database;
    final res = await db.rawDelete('DELETE FROM Scans');
    return res;
  }

}