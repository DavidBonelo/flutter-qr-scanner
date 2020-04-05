import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:qrscanner/src/models/scan_model.dart';

class MapaPage extends StatefulWidget {

  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  final mapController = new MapController();
  String tipoMapa = 'streets';

  @override
  Widget build(BuildContext context) {
  
  final ScanModel scan = ModalRoute.of(context).settings.arguments;
  
    return Scaffold(
      appBar: AppBar(
        title: Text('Coordenadas QR'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: (){
              mapController.move(scan.getLatLng(), 15.0);
            },
          )
        ],
      ),
      body: _crearFlutterMap(scan),
      floatingActionButton: _crearFAB(context),
      
    );
  }

  Widget _crearFlutterMap(ScanModel scan) {
    return new FlutterMap(
      // Para controlar la posicion el el mapa
      mapController: mapController,
      options: MapOptions(
        center: scan.getLatLng(),
        zoom: 15.0,
      ),
      layers: [
        _crearMapa(),
        _crearMarcadores(scan),
      ],
    );
  }

  _crearMapa(){

    // vector /v4/{tileset_id}/{zoom}/{x}/{y}{@2x}.{format}
    // example
    // "https://api.mapbox.com/v4/mapbox.mapbox-streets-v8/1/0/0.mvt?access_token=pk.eyJ1IjoiYm9uZWxvZGV2IiwiYSI6ImNrOG00NDJ2ajBqbHgzaW53bzExeG5ldW0ifQ.mnorf_TWq2tfFLjnKY8GlQ"
    // raster /v4/{tileset_id}/{zoom}/{x}/{y}{@2x}.{format}
    // example
    // "https://api.mapbox.com/v4/mapbox.satellite/1/0/0@2x.jpg90?access_token=pk.eyJ1IjoiYm9uZWxvZGV2IiwiYSI6ImNrOG00NDJ2ajBqbHgzaW53bzExeG5ldW0ifQ.mnorf_TWq2tfFLjnKY8GlQ"


    // pk.eyJ1IjoiYm9uZWxvZGV2IiwiYSI6ImNrOG00dWJ0cjBiajEzbG12bmx4a3FxbGwifQ.Mzn3yIfvthME2D26MUH-9g
    return TileLayerOptions(
      urlTemplate: 'https://api.mapbox.com/v4/{id}/{z}/{x}/{y}@2x.jpg90?access_token={accessToken}',
      additionalOptions: {
        'accessToken': 'pk.eyJ1IjoiYm9uZWxvZGV2IiwiYSI6ImNrOG00dWJ0cjBiajEzbG12bmx4a3FxbGwifQ.Mzn3yIfvthME2D26MUH-9g',
        'id' : 'mapbox.$tipoMapa'
        // streets, dark, light, ooutdoors, satelite
      }
    ); 
  }

  _crearMarcadores(ScanModel scan) {
    return MarkerLayerOptions(
      markers: <Marker>[
        Marker(
          width: 100.0,
          height: 100.0,
          point: scan.getLatLng(),
          builder: (context) => Container(
            child: Icon(
              Icons.location_on,
              size: 70.0,
              color: Theme.of(context).primaryColor,
            )
          )
        )
      ]
    );
  }

  Widget _crearFAB(BuildContext context) {
    return FloatingActionButton(

      child: Icon(Icons.repeat),
      // streets, dark, light, ooutdoors, satelite
      onPressed: () => setState((){
        if (tipoMapa == 'streets') {
          tipoMapa = 'dark';
        } else if (tipoMapa == 'dark') {
          tipoMapa = 'light';
        } else if (tipoMapa == 'light') {
          tipoMapa = 'ooutdoors';
        } else if (tipoMapa == 'ooutdoors') {
          tipoMapa = 'satelite';
        } else {
          tipoMapa = 'streets';
        }
      })
    );

  }
}