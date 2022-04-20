import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:navitrack_map/DataModel.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  StreamController<DataModel> _streamController = StreamController();
  Completer<GoogleMapController> _controller = Completer();
  late BitmapDescriptor mapMarker;

  @override
  void dispose() {
    _streamController.close();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Timer.periodic(Duration(seconds: 1), (timer) {
      getLiveData();
      setCustomMarker();
    });
  }

  Future<void> getLiveData() async{
    var url = Uri.parse('https://mrjava-rest-tls.herokuapp.com/box-tracks/get-all');

    final response = await http.get(url);

    final databody = json.decode(response.body).last;

    DataModel dataModel = new DataModel.fromJson(databody);

    print(databody);

    _streamController.sink.add(dataModel);
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder<DataModel>(
          stream: _streamController.stream,
          builder: (context,snapdata){
            switch(snapdata.connectionState){
              case ConnectionState.waiting: return Center(child: CircularProgressIndicator(),);
              default: if(snapdata.hasError){
                return Text('Wait please');
              }else{
                return BuildRealtimeData(snapdata.data!);

              }
            }
          },
        ),
      ),
    );

  }

void setCustomMarker() async{
    mapMarker =await BitmapDescriptor.fromAssetImage(ImageConfiguration(), 'assets/vehicule.png');
}

  Widget BuildRealtimeData(DataModel dataModel){
    return Column(
      children: [
        Expanded(
          child: GoogleMap(
            mapType: MapType.satellite,
            markers: {
              Marker(
                markerId: MarkerId('_navitrackTracking'),
                //infoWindow: InfoWindow(title: 'vitesse : ${dataModel.vitesse}'),
                icon: mapMarker,
                position: LatLng(dataModel.latitude, dataModel.longitude)
            )},
            initialCameraPosition: CameraPosition(
              target: LatLng(dataModel.latitude, dataModel.longitude),
              zoom: 14,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        ),
      ],
    );
  }

}
