// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../Groups/GroupClass.dart';

class MapPage extends StatefulWidget {
  final String userId;

  const MapPage({Key? key, required this.userId}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  LatLng? currentLocation;
  bool toggle = false; // Initial state of toggle is true
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int? clickedIndex; // Store the clicked index
  late CollectionReference<Map<String, dynamic>> groupsRef;
  late List<Group> _joinedGroups;
  late String _selectedGroupName = '';
  List<String> stringList = [];
  List<LatLng> locationList = [];

  @override
  void initState() {
    super.initState();
    _checkLocationPermission(context);
    _joinedGroups = [];
    _getGroups();
  }

  Future<void> _getGroups() async {
    final groupsSnapshot =
        await FirebaseFirestore.instance.collection('Group').get();

    final joinedGroups = groupsSnapshot.docs
        .where((doc) => doc['members'].contains(widget.userId))
        .map((doc) => Group.fromDocument(doc))
        .toList();

    setState(() {
      _joinedGroups = joinedGroups;
    });
  }

  void _updateMarkers(Marker newMarker) async {
    setState(() {
      markers.add(newMarker);
    });

    final currentLocation = await getCurrentLocation();
    if (mapController != null && currentLocation != null) {
      mapController!.animateCamera(CameraUpdate.newLatLngZoom(
        currentLocation,
        10.0,
      ));
    }
  }

  Future<LatLng?> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<void> _checkLocationPermission(BuildContext context) async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
      final newPermission = await Geolocator.checkPermission();
      if (newPermission == LocationPermission.denied) {
        return; // Permission still denied, do not proceed
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return; // Permission permanently denied, do not proceed
    }
  }

  void _toggleLocationDisplay() {
    setState(() {
      toggle = !toggle; // Switch the state of toggle when the button is clicked
    });
  }

  Future<void> fetchLocations(String groupName, List<String> stringList,
      List<LatLng> locationList, String userId) async {
    final groupDoc = await FirebaseFirestore.instance
        .collection('Group')
        .where('name', isEqualTo: groupName)
        .get()
        .then((value) => value.docs.first);

    final locationsCollection = groupDoc.reference.collection('locations');
    final locationsDocs = await locationsCollection.get();

    bool foundUserDoc = false;
    for (final doc in locationsDocs.docs) {
      final location = doc.get('Location') as GeoPoint;
      final name = doc.id;
      stringList.add(name);
      locationList.add(LatLng(location.latitude, location.longitude));
      if (doc.id == userId) {
        foundUserDoc = true;
      }
    }

    if (!foundUserDoc) {
      final location = await getCurrentLocation();
      if (location != null) {
        final docRef = locationsCollection.doc(userId);
        await docRef
            .set({'Location': GeoPoint(location.latitude, location.longitude)});
        stringList.add(userId);
        locationList.add(LatLng(location.latitude, location.longitude));
      }
    }

    for (final latLng in locationList) {
      final marker = Marker(
        markerId: MarkerId(latLng.toString()),
        position: latLng,
        infoWindow: InfoWindow(
          title: stringList[locationList.indexOf(latLng)],
        ),
      );
      _updateMarkers(marker);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Set the key to access the ScaffoldState
      appBar: AppBar(
        title: const Text("Map Page"),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: currentLocation == null
                ? GoogleMap(
                    zoomGesturesEnabled: true,
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(0, 0), // Set target to 0,0
                      zoom: 10.0,
                    ),
                    markers: markers,
                    mapType: MapType.normal,
                    onMapCreated: (controller) {
                      setState(() {
                        mapController = controller;
                      });
                    },
                  )
                : GoogleMap(
                    zoomGesturesEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: currentLocation!,
                      zoom: 10.0,
                    ),
                    markers: markers,
                    // Display markers only if toggle is true
                    mapType: MapType.normal,
                    onMapCreated: (controller) {
                      setState(() {
                        mapController = controller;
                      });
                    },
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Location: '),
              ElevatedButton(
                onPressed: () {
                  _toggleLocationDisplay();
                  stringList.clear();
                  locationList.clear();
                  markers.clear();
                  if (toggle && _selectedGroupName.isNotEmpty) {
                    fetchLocations(_selectedGroupName, stringList, locationList,
                        widget.userId);
                  }
                },
                child: Text(toggle ? 'Turn Off' : 'Turn On'),
              ),
            ],
          ),
          Expanded(
            flex: 1,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _joinedGroups
                  .where((group) => group.members.contains(widget.userId))
                  .length,
              itemBuilder: (context, index) {
                final joinedGroupsList = _joinedGroups
                    .where((group) => group.members.contains(widget.userId))
                    .toList();
                final group = joinedGroupsList[index];
                return ListTile(
                  title: Text(group.name),
                  onTap: () {
                    setState(() {
                      _selectedGroupName = group
                          .name; // store the group name in another variable
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Group $_selectedGroupName clicked on"),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
