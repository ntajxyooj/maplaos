import 'dart:async';

import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:flutter/material.dart';
import 'package:maplaos/model/add_location.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maplaos/setting/setting.dart';
import 'package:maplaos/model/loadimg.dart';

class ModelLocationView extends StatefulWidget {
  @override
  int locationId;
  ModelLocationView(this.locationId);
  _ModelLocationViewState createState() =>
      _ModelLocationViewState(this.locationId);
}

class _ModelLocationViewState extends State<ModelLocationView> {
  int locationId;
  _ModelLocationViewState(this.locationId);

  Setting setting = new Setting();
  bool isloading = true;
  var locationlist;
  void loadinglocation(locationId) async {
    final conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
        host: setting.host,
        port: setting.port,
        user: setting.user,
        password: setting.password,
        db: setting.db));
    var locations =
        await conn.query("select * from location left join provinces on provinces.id=location.provinces_id left join districts on districts.id=location.districts_id left join location_details on location_details.location_id=location.id where location.id=?", [locationId]);
    for (var location in locations) {
      setState(() {
        locationlist = location;
        isloading = false;
      });
    }
    print(locationlist['latitude']);
  }

/*=================== switch map type ===========*/
  MapType _currentMapType = MapType.normal;
  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  Completer<GoogleMapController> _controller = Completer();

  void showdetail() async {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20.0),
                topRight: const Radius.circular(20.0))),
        backgroundColor: Colors.white,
        context: context,
        builder: (Builder) {
          String name = locationlist['status'].toString() == 'Open'
              ? AppLocalizations.of(context).tr('Public')
              : AppLocalizations.of(context).tr('Pedding');
          return SingleChildScrollView(
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      decoration: new BoxDecoration(
                          color: Colors.red,
                          borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(20.0),
                              topRight: const Radius.circular(20.0))),
                      padding: EdgeInsets.all(10),
                      //color: Colors.red,
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context).tr('Details'),
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ListTile(
                            leading: CircleAvatar(
                                backgroundImage: AssetImage('assets/map.png')),
                            title: Localizations.localeOf(context)
                                        .languageCode ==
                                    "en"
                                ? Text(locationlist['loc_name'].toString())
                                : Text(locationlist['loc_name_la'].toString()),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  AppLocalizations.of(context).tr('Latitude') +
                                      ": " +
                                      locationlist['latitude'].toString(),
                                  style: TextStyle(fontSize: 10.0),
                                ),
                                Text(
                                  AppLocalizations.of(context)
                                          .tr('Longtitude') +
                                      ": " +
                                      locationlist['longitude'].toString(),
                                  style: TextStyle(fontSize: 10.0),
                                ),
                                Text(
                                  AppLocalizations.of(context).tr('Status') +
                                      ": $name",
                                  style: TextStyle(
                                      fontSize: 10.0,
                                      color:
                                          locationlist['status'].toString() ==
                                                  'Pedding'
                                              ? Colors.red
                                              : Colors.green),
                                ),
                              ],
                            ),
                          ),
                          Loadimg(locationlist['id']),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    loadinglocation(locationId);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isloading
            ? Text("")
            : Localizations.localeOf(context).languageCode == "en"
                ? Text(locationlist['loc_name'].toString())
                : Text(locationlist['loc_name_la'].toString()),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.edit_location,
              color: Colors.blue,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddLocation(this.locationId)),
              );
            },
          ),
        ],
      ),
      body: isloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              mapType: _currentMapType,
              myLocationEnabled: true,
              compassEnabled: true,
              initialCameraPosition: CameraPosition(
                target:
                    LatLng(locationlist['latitude'], locationlist['longitude']),
                zoom: 15,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                // mapController = controller;
              },
              markers: {
                  Marker(
                      markerId: MarkerId('id123'),
                      position: LatLng(
                          locationlist['latitude'], locationlist['longitude']),
                      onTap: () {
                        showdetail();
                      }),
                }),
      floatingActionButton: FloatingActionButton(
        onPressed: _onMapTypeButtonPressed,
        child: new Icon(
          Icons.map,
          color: Colors.white,
        ),
      ),
    );
  }
}
