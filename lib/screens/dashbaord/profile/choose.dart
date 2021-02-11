import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supplier/utils/colors.dart';

class ChooseMyLocation extends StatefulWidget {
  ChooseMyLocation({this.callback});
  LatLng location;
  VoidCallback callback;
  @override
  _ChooseMyLocationState createState() => _ChooseMyLocationState();
}

class _ChooseMyLocationState extends State<ChooseMyLocation> {
  Position position;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initLocation();
  }

  initLocation() async {
    position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    widget.location = LatLng(position.latitude, position.longitude);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = new Set();
    if (position != null) {
      markers.add(new Marker(
          markerId: new MarkerId("idid"),
          position: LatLng(position.latitude, position.longitude)));
    }
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Map"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          widget.callback();
          Navigator.of(context).pop();
        },
        child: Icon(Icons.done),
        backgroundColor: purpleColor,
      ),
      body: position == null
          ? Center(
              child: new CircularProgressIndicator(),
            )
          : GoogleMap(
              onTap: (newLocation) {
                setState(() {
                  position = new Position(
                      latitude: newLocation.latitude,
                      longitude: newLocation.longitude);
                  widget.location = newLocation;
                });
              },
              markers: markers,
              initialCameraPosition: CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 15),
            ),
    );
  }
}
