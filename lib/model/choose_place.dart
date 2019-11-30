import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:maplaos/model/add_location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

class DragMarkerMap extends StatefulWidget {
  @override
  _DragMarkerMapState createState() => _DragMarkerMapState();
}

class _DragMarkerMapState extends State<DragMarkerMap> {
  Completer<GoogleMapController> _controller = Completer();

  static LatLng _center = LatLng(45.521563, -122.677433);

  Set<Marker> _markers = {};

  LatLng _lastMapPosition = _center;

  MapType _currentMapType = MapType.normal;

  /*================ Loading current location  =================*/
  bool isgetcurrent = true;
  void getcurrentlocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    location.LocationData currentLocation =
        await location.Location().getLocation();
    prefs.setDouble('lat', currentLocation.latitude);
    prefs.setDouble('long', currentLocation.longitude);
    setState(() {
      _center = LatLng(currentLocation.latitude, currentLocation.longitude);
      isgetcurrent = false;
    });
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _updatePosition(CameraPosition _position) {
    print(
        'inside updatePosition ${_position.target.latitude} ${_position.target.longitude}');
    Marker marker = _markers.firstWhere(
        (p) => p.markerId == MarkerId('marker_id'),
        orElse: () => null);

    _markers.remove(marker);
    _markers.add(
      Marker(
        markerId: MarkerId('marker_id'),
        position: LatLng(_position.target.latitude, _position.target.longitude),
        draggable: true,
        icon: BitmapDescriptor.defaultMarker,
      ),
    );
    setState(() {
      _lastMapPosition =
          LatLng(_position.target.latitude, _position.target.longitude);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    getcurrentlocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).tr('Choose place')),
        backgroundColor: Colors.red,
      ),
      body: isgetcurrent
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: <Widget>[
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  myLocationEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 15.0,
                  ),
                  mapType: _currentMapType,
                  markers: _markers,
                  onCameraMove: _updatePosition,
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: FloatingActionButton(
                          onPressed: _onMapTypeButtonPressed,
                          child: new Icon(
                            Icons.map,
                            color: Colors.white,
                          ),
                        ),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Align(
                      alignment: Alignment.bottomRight,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: FloatingActionButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddLocation(null),
                                ));
                          },
                          child: Icon(Icons.navigate_next),
                          backgroundColor: Colors.blue,
                        ),
                      )),
                ),
              ],
            ),
    );
  }
}