import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:oturans/car_price.dart';
import 'package:uuid/uuid.dart';

import 'bookings.dart';
import 'main.dart';

class location extends StatefulWidget {
  final String phonenumber;
  final String name;
  const location({super.key, required this.phonenumber, required this.name});

  @override
  State<location> createState() => _locationState();
}

class _locationState extends State<location> {
  final TextEditingController _location1 = TextEditingController();
  final TextEditingController _location2 = TextEditingController();
  final TextEditingController _date = TextEditingController();
  final TextEditingController _time = TextEditingController();
  var uuid = const Uuid();
  final String token = '1234567890';

  @override
  void initState() {
    super.initState();
    // _getcurrentlocation();
    _location1.addListener(() {
      // setState(() {

      // });
      placeSuggestion(_location1.text);
    });
    _location2.addListener(() {
      // setState(() {

      // });
      placeSuggestion(_location2.text);
    });
  }

  List<String> _placeid = [];
  List<Map<String, dynamic>> locationlist = [];
  void placeSuggestion(String input) async {
    const String apikey = "AIzaSyAck8G7k-7p1gCPQmxsTZ5l6Yc3Xg-v2Y4";
    try {
      String bassedUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json";
      String request = '$bassedUrl?input=$input&key=$apikey';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {
          locationlist = List<Map<String, dynamic>>.from(data['predictions']);

          _placeid =
              locationlist.map((item) => item['place_id'].toString()).toList();
        });
      } else {
        throw Exception('Failed to load');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  FocusNode f1 = FocusNode();
  FocusNode f2 = FocusNode();
  Set<Marker> _markers = {};
  String distance = "";
  String estd = "";
  final Set<Polyline> _polylines = {};

  String placeid1 = '';
  String placeid2 = '';
  Future<void> _getcordinates() async {
    const String apikey = "AIzaSyAck8G7k-7p1gCPQmxsTZ5l6Yc3Xg-v2Y4";
    try {
      String detailsUrl =
          "https://maps.googleapis.com/maps/api/directions/json?origin=place_id:$placeid1&destination=place_id:$placeid2&key=$apikey";

      var response = await http.get(Uri.parse(detailsUrl));
      // print(response.statusCode);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        double startLat = data["routes"][0]["legs"][0]["start_location"]["lat"];
        double startLng = data["routes"][0]["legs"][0]["start_location"]["lng"];
        print("$startLat , $startLng ");
        double endLat = data["routes"][0]["legs"][0]["end_location"]["lat"];
        double endLng = data["routes"][0]["legs"][0]["end_location"]["lng"];
        print("$endLat , $endLng ");
        distance = data["routes"][0]["legs"][0]["distance"]["text"];
        estd = data["routes"][0]["legs"][0]["duration"]["text"];
        if (data["routes"].isNotEmpty) {
          final points = data["routes"][0]["overview_polyline"]["points"];
          final List<LatLng> _polycordinates = decodepolyline(points);

          setState(() {
            _markers.add(Marker(
              markerId: MarkerId('Source'),
              position: LatLng(startLat, startLng),
            ));
            _markers.add(Marker(
              markerId: MarkerId('Destination'),
              position: LatLng(endLat, endLng),
            ));

            _polylines.add(Polyline(
                polylineId: PolylineId("route"),
                points: _polycordinates,
                color: Colors.blue,
                width: 5));
          });
          print("${_polycordinates.first}  ${_polycordinates.last}");
          setState(() {
            mapcontroller.animateCamera(CameraUpdate.newLatLngBounds(
              LatLngBounds(
                northeast: LatLng(
                    _polycordinates.first.latitude >
                            _polycordinates.last.latitude
                        ? _polycordinates.first.latitude
                        : _polycordinates.last.latitude,
                    _polycordinates.first.longitude >
                            _polycordinates.last.longitude
                        ? _polycordinates.first.longitude
                        : _polycordinates.last.longitude),
                southwest: LatLng(
                    _polycordinates.first.latitude <
                            _polycordinates.last.latitude
                        ? _polycordinates.first.latitude
                        : _polycordinates.last.latitude,
                    _polycordinates.first.longitude <
                            _polycordinates.last.longitude
                        ? _polycordinates.first.longitude
                        : _polycordinates.last.longitude),
              ),
              100,
            ));
          });
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('No Routes found')));
        }
      } else {
        throw Exception('Failed to load place details');
      }
    } catch (e) {
      print('excpetion${e.toString()}');
    }
  }

  List<LatLng> decodepolyline(String enc) {
    List<LatLng> dec = [];
    int index = 0, len = enc.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int shift = 0, result = 0;
      int b;
      do {
        b = enc.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int declat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += declat;
      shift = 0;
      result = 0;
      do {
        b = enc.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int declng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += declng;

      dec.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return dec;
  }

  late GoogleMapController mapcontroller;
  CameraPosition _initialposition = CameraPosition(
    target: LatLng(11.258753, 75.780411),
    zoom: 14,
  );

  DateTime selectedDateTime = DateTime.now();

  Future<void> _pickDateTime() async {
    // Pick the date
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      // If date is selected, update the selected date while keeping the current time
      setState(() {
        selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          selectedDateTime.hour,
          selectedDateTime.minute,
        );
      });
    }

    // Pick the time
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
    );

    if (pickedTime != null) {
      // If time is selected, update the selected time while keeping the current date
      setState(() {
        selectedDateTime = DateTime(
          selectedDateTime.year,
          selectedDateTime.month,
          selectedDateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
    setState(() {
      _date.text = selectedDateTime.toString();
    });
  }

  void logout(BuildContext context) async {
    DocumentReference userDoc =
        FirebaseFirestore.instance.collection('DATA').doc(widget.phonenumber);
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('DATA')
        .doc(widget.phonenumber)
        .get();

    await userDoc.update({
      'Bookings': 0,
    });
    var temp = await FirebaseFirestore.instance
        .collection('DATA')
        .doc(widget.phonenumber)
        .collection('bookings');
    var querysnap = await temp.get();
    for (var doc in querysnap.docs) {
      await doc.reference.delete();
    }

    await FirebaseAuth.instance.signOut();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Successfully logged out")));

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
        (Route<dynamic> route) => false);
  }

  @override
  void dispose() {
    _time.dispose();
    _location1.dispose();
    _location2.dispose();
    _date.dispose();
    removeoverlay();
    super.dispose();
  }

  final LayerLink _layerlink = LayerLink();
  final LayerLink _layerlink2 = LayerLink();
  OverlayEntry? _overlayentry;
  OverlayEntry? _overlayentry2;

  void showoverlay() {
    removeoverlay();
    if (_overlayentry != null) return;
    _overlayentry = OverlayEntry(
        builder: (context) => Positioned(
              width: MediaQuery.of(context).size.width - 100,
              child: CompositedTransformFollower(
                link: _layerlink,
                showWhenUnlinked: false,
                offset: Offset(0, 65),
                child: Material(
                  elevation: 4,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: locationlist.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.pin_drop),
                        title: Text(locationlist[index]["description"]),
                        onTap: () async {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              placeid1 = _placeid[index];
                              _location1.text =
                                  locationlist[index]["description"];
                              removeoverlay();
                              _getcordinates();
                            });
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ));
    Overlay.of(context).insert(_overlayentry!);
  }

  void showoverlay2() {
    removeoverlay2();
    if (_overlayentry2 != null) return;
    _overlayentry2 = OverlayEntry(
        builder: (context) => Positioned(
              width: MediaQuery.of(context).size.width - 100,
              child: CompositedTransformFollower(
                link: _layerlink2,
                showWhenUnlinked: false,
                offset: Offset(0, 65),
                child: Material(
                  elevation: 4,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: locationlist.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.pin_drop),
                        title: Text(locationlist[index]["description"]),
                        onTap: () async {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              placeid2 = _placeid[index];
                              _location2.text =
                                  locationlist[index]["description"];
                              removeoverlay2();
                              _getcordinates();
                            });
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ));
    Overlay.of(context).insert(_overlayentry2!);
  }

  void removeoverlay() {
    _overlayentry?.remove();
    _overlayentry = null;
  }

  void removeoverlay2() {
    _overlayentry2?.remove();
    _overlayentry2 = null;
  }

  void onTextChanged(String text) {
    if (text.isNotEmpty) {
      setState(() {
        showoverlay();
      });
    } else {
      setState(() {
        removeoverlay();
      });
    }
  }

  void onTextChanged2(String text) {
    if (text.isNotEmpty) {
      setState(() {
        showoverlay2();
      });
    } else {
      setState(() {
        removeoverlay2();
      });
    }
  }

  bool is_expand = false;
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              child: Container(
                decoration: BoxDecoration(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      child: Image.asset(
                        'assets/img/user.png',
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${widget.name}',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            '${widget.phonenumber}',
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_2),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => profile()));
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.date_range_rounded),
            //   title: const Text('Bookings'),
            //   onTap: () => Navigator.push(context,
            //       MaterialPageRoute(builder: (context) => const bookings())),
            // ),
            ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigator.pop(context);
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context) => about()));
                }),

            ListTile(
              leading: const Icon(Icons.exit_to_app_rounded),
              title: const Text('Logout'),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Logout"),
                        content: Text(
                            " Logging out will clear all your data and bookings."),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.all(Colors.black),
                                    foregroundColor:
                                        WidgetStateProperty.all(Colors.white),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("Cancel")),
                              TextButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.all(Colors.black),
                                    foregroundColor:
                                        WidgetStateProperty.all(Colors.white),
                                  ),
                                  onPressed: () async {
                                    logout(context);
                                  },
                                  child: Text("Yes"))
                            ],
                          )
                        ],
                      );
                    });
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.white)),
              child: GoogleMap(
                initialCameraPosition: _initialposition,
                onMapCreated: (GoogleMapController controller) {
                  mapcontroller = controller;
                },
                markers: _markers,
                polylines: _polylines,
              ),
            ),
            Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Container(
                      height: 275,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            CompositedTransformTarget(
                              link: _layerlink,
                              child: TextField(
                                focusNode: f1,
                                controller: _location1,
                                onChanged: onTextChanged,
                                decoration: const InputDecoration(
                                  hintText: "Enter the Source",
                                  hintStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  icon: Icon(
                                    Icons.my_location_rounded,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25))),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(25)),
                                      borderSide: BorderSide(
                                          color: Colors.white, width: 5)),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            CompositedTransformTarget(
                              link: _layerlink2,
                              child: TextField(
                                focusNode: f2,
                                controller: _location2,
                                onChanged: onTextChanged2,
                                decoration: const InputDecoration(
                                  hintText: "Enter the Destination",
                                  hintStyle:
                                      TextStyle(fontWeight: FontWeight.bold),
                                  icon: Icon(
                                    Icons.pin_drop,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25))),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(25)),
                                      borderSide: BorderSide(
                                          color: Colors.white, width: 5)),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  child: IconButton(
                                    onPressed: () {
                                      _pickDateTime();
                                    },
                                    icon: Icon(
                                      Icons.timelapse_sharp,
                                      color: Colors.black,
                                      size: 40,
                                    ),
                                  ),
                                )
                                // Text(_selectdate == null
                                //     ? "No date selected"
                                //     : "${_selectdate.toLocal()}".split(' ')[0]),
                                // const SizedBox(
                                //   width: 50,
                                // ),
                                // IconButton(
                                //   onPressed: () {
                                //     timeselector(context);
                                //   },
                                //   icon: Icon(Icons.timer_sharp,
                                //       color: Colors.black),
                                // ),
                                // Text(
                                //   _timenow == null
                                //       ? "Pick-In Time"
                                //       : _timenow.format(context),
                                // ),
                                // ,
                                ,
                                Container(
                                  child: Text(
                                    _date.text.isNotEmpty
                                        ? '${_date.text.split(' ')[0]}  ${selectedDateTime.hour}:${selectedDateTime.minute}'
                                        : "Select Date And Time",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: TextButton(
                              style: ButtonStyle(
                                  foregroundColor:
                                      WidgetStatePropertyAll(Colors.white),
                                  backgroundColor:
                                      WidgetStatePropertyAll(Colors.black)),
                              onPressed: () {
                                /*
                                */
                                if (selectedDateTime.isBefore(DateTime.now()) ||
                                    selectedDateTime == DateTime.now()) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text("Invalid Date or Time")));
                                } else if (_location1.text == _location2.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Source and Destination Cannot be Same")));
                                } else if (_location1.text.isNotEmpty &&
                                    _location2.text.isNotEmpty &&
                                    _location1.text != _location2.text) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => car_price(
                                              name: widget.name,
                                              phone: widget.phonenumber,
                                              source: _location1.text,
                                              dest: _location2.text,
                                              date: selectedDateTime,
                                              time: selectedDateTime,
                                              estdtime: estd,
                                              distance: distance)));
                                }
                              },
                              child: Text(
                                "SELECT CAB",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ))),
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.75,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                    child: Column(
                  children: [
                    FloatingActionButton(
                        heroTag: 'tag1',
                        backgroundColor: Colors.black,
                        child: Icon(
                          Icons.book_outlined,
                          color: Colors.white,
                        ),
                        shape: CircleBorder(
                          side: BorderSide.none,
                          eccentricity: 0.0,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => bookings(
                                        phone: widget.phonenumber,
                                      )));
                        }),
                    const SizedBox(
                      height: 10,
                    ),
                    FloatingActionButton(
                        heroTag: 'tag2',
                        backgroundColor: Colors.black,
                        child: Icon(
                          Icons.settings,
                          color: Colors.white,
                        ),
                        shape: CircleBorder(
                          side: BorderSide.none,
                          eccentricity: 0.0,
                        ),
                        onPressed: () {
                          _scaffoldkey.currentState?.openDrawer();
                        }),
                  ],
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
