import 'dart:async';

import 'package:qrscanner/src/bloc/validator.dart';
import 'package:qrscanner/src/providers/db_provider.dart';

class ScansBloc with Validators{

  static final ScansBloc _singleton = new ScansBloc._internal();

  factory ScansBloc() {
    return _singleton;
  }
  ScansBloc._internal(){
    // Obtener los Scans de la db
    obtenerScans();
  }

  final _scansController = StreamController<List<ScanModel>>.broadcast();

  Stream<List<ScanModel>> get scansStreamHttp => _scansController.stream.transform(validarHttp);
  Stream<List<ScanModel>> get scansStreamGeo  => _scansController.stream.transform(validarGeo);

  dispose(){
    _scansController?.close();
  }

  obtenerScans() async {
    _scansController.sink.add(await DBProvider.db.getTodosScans());
  }

  agregarScan(ScanModel newScan) async {
    await DBProvider.db.nuevoScan(newScan);
    obtenerScans();
  }

  borrarScan( int id ) async {
    await DBProvider.db.deleteScan(id);
    obtenerScans();
  }

  borrarScansTODOS() async {
    await DBProvider.db.deleteAll();
    obtenerScans();
  }
  
}