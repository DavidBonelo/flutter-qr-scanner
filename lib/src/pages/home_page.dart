import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qrscanner/src/bloc/scans_bloc.dart';
import 'package:qrscanner/src/models/scan_model.dart';

import 'package:qrscanner/src/pages/scans_fragment.dart';
import 'package:qrscanner/src/utils/scan_utils.dart' as utils;

import 'package:barcode_scan/barcode_scan.dart';
// import 'package:qrcode_reader/qrcode_reader.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final scansBloc = new ScansBloc();

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Scanner'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: scansBloc.borrarScansTODOS
          )
        ],
      ),
      body: _callPage(currentIndex),
      bottomNavigationBar: _crearBottomNavigationBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.filter_center_focus),
        onPressed: ()=>_scanQR(context),
      ),
    );
  }
  _scanQR(BuildContext context) async {
    // https://google.com
    // geo:40.724233047051705,-74.00731459101564

    String futureString;

    // OJO, recordar que para ios hay que agregar el permiso para la camara
    // Abrir el archivo que se encuentra en la carpeta ios >> Runner >> Info.plist y agregar esto:
    
    // <key>NSCameraUsageDescription</key>
    // <string>Necesito acceso a la cámara para leer QRs</string>
    
    // Lanza la camara para capturar el codigo QR
    try {
      // futureString = await new QRCodeReader().scan();
      futureString = await BarcodeScanner.scan();
    } catch(e){
      futureString = null;
      // TODO: Agregar toast cuando no se pueda hacer el scaneo (permisos?)
      // futureString = e.toString();
    }

    if (futureString != null){
      final scan = ScanModel(valor: futureString);
      scansBloc.agregarScan(scan);

      // Abre el enlace o el mapa del codigo QR.
      // Retraso 1s en ios porque la camara tiene una animacion de cerrado que tarda
      if ( Platform.isIOS ) {
        Future.delayed(Duration(seconds: 1), (){
          utils.abrirScan(context, scan);
        });
      } else {
        utils.abrirScan(context, scan);
      }
      // TODO: Agregar toast cuando se cancele el scaneo

    }
  }

  Widget _callPage(int paginaActual){
    switch (paginaActual) {
      case 0:  return ScansListFragment(stream: scansBloc.scansStreamHttp); break;
      case 1:  return ScansListFragment(stream: scansBloc.scansStreamGeo); break;
      default: return ScansListFragment(stream: scansBloc.scansStreamHttp); break;
    }
  }

  Widget _crearBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.link),
          title: Text('Enlaces')
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          title: Text('Mapas')
        ),
      ],
      onTap: (index){
        setState(() {
          currentIndex = index;
        });
      },
    );
  }
  @override
  void dispose() {
    scansBloc.dispose();
    super.dispose();
  }
}