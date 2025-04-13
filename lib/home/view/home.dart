import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color primaryColor = Color(0xFF2C5F2D);
  static const Color accentColor = Color(0xFF97BC62);
  static const Color warningColor = Color(0xFFE74C3C);
  Set<Polygon> polygons = {};
  late GoogleMapController mapController;
  LatLng _center = const LatLng(14.6507, 121.1029);
  LatLng? _currentLocation;
  String? selectedLocation;
  bool isOverlayVisible = false;
  List<LatLng> marikinaBoundary = [];
  Set<Polyline> _polylines = {};
  List<LatLng> _routeCoords = [];
  BitmapDescriptor? customMarkerIcon;
  // Navigation variables
  bool _isNavigating = false;
  LocationData? _currentLocationData;
  StreamSubscription<LocationData>? _locationSubscription;
  String? _distanceText;
  String? _durationText;
  DateTime? _lastRouteUpdate;
  double _cameraTilt = 45.0;
  double _cameraZoom = 17.0;
  FocusNode _searchFocusNode = FocusNode();
  // Search functionality variables
  final TextEditingController _searchController = TextEditingController();
  Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> _markers = {};
  // For autocomplete suggestions
  List<String> _suggestions = [];
  bool _showSuggestions = false;
  List<Map<String, dynamic>> _routeSteps = [];
  int _currentStepIndex = 0;
  String _currentInstruction = "";
  String _nextInstruction = "";
  String _googleApiKey = 'AIzaSyAygw1kv0qn5tL_HHx4xohp-oi1sUky0jk';

  final List<Map<String, dynamic>> locations = [
    {
      "name": "Our Lady of the Abandoned Church",
      "src": "assets/images/landmark/ola.PNG",
      "lat": 14.63083,
      "lng": 121.09583,
      "type": "spot"
    },
    {
      "name": "Immaculate Conception Parish Church",
      "src": "assets/images/landmark/concep church.PNG",
      "lat": 14.65111,
      "lng": 121.10389,
      "type": "spot"
    },
    {
      "name": "St. Paul of the Cross",
      "src": "assets/images/landmark/st paul.PNG",
      "lat": 14.63972,
      "lng": 121.12056,
      "type": "spot"
    },
    {
      "name": "Jesus dela Peña Chapel",
      "src": "assets/images/landmark/jesus dela pena.PNG",
      "lat": 14.63389,
      "lng": 121.09167,
      "type": "spot"
    },
    {
      "name": "San Isidro Labrador Parish",
      "src": "assets/images/landmark/san isidro.PNG",
      "lat": 14.67000,
      "lng": 121.10722,
      "type": "spot"
    },
    {
      "name": "Book Museum cum Ethnology Center",
      "src": "assets/images/landmark/sports complex.PNG",
      "lat": 14.65056,
      "lng": 121.11945,
      "type": "spot"
    },
    {
      "name": "Marikina Shoe Museum",
      "src": "assets/images/landmark/shoe museum.PNG",
      "lat": 14.62944,
      "lng": 121.09611,
      "type": "spot"
    },
    {
      "name": "The Spirit of Bethlehem Museum",
      "src": "assets/images/landmark/betlehem museum.PNG",
      "lat": 14.62917,
      "lng": 121.08139,
      "type": "spot"
    },
    {
      "name": "Marikina Sports Complex",
      "src": "assets/images/landmark/book museum.PNG",
      "lat": 14.63278,
      "lng": 121.09694,
      "type": "spot"
    },
    {
      "name": "Marikina City Hood Park",
      "src": "assets/images/landmark/city hood park.PNG",
      "lat": 14.63472,
      "lng": 121.09750,
      "type": "spot"
    },
    {
      "name": "Riverbanks Center",
      "src": "assets/images/landmark/river banks.PNG",
      "lat": 14.63194,
      "lng": 121.08333,
      "type": "spot"
    },
    {
      "name": "Marikina River Park",
      "src": "assets/images/landmark/river park.PNG",
      "lat": 14.63306,
      "lng": 121.09306,
      "type": "spot"
    },
    // {
    //   "name": "Philippine Science Centrum",
    //   "src": "assets/images/landmark/science centrum.PNG",
    //   "lat": 14.6222,
    //   "lng": 121.0833,
    //   "type": "spot"
    // },
    {
      "name": "Rustic Mornings by Isabelo",
      "src": "assets/images/landmark/rustic morning.PNG",
      "lat": 14.62889,
      "lng": 121.09583,
      "type": "spot"
    },
    {
      "name": "Cafe Lidia",
      "src": "assets/images/landmark/cafe lidia.PNG",
      "lat": 14.62139,
      "lng": 121.09528,
      "type": "spot"
    },
    {
      "name": "Vikings Luxury Buffet",
      "src": "assets/images/landmark/vikings lucury buffet.PNG",
      "lat": 14.60806,
      "lng": 121.08083,
      "type": "spot"
    },
    {
      "name": "Krung Thai",
      "src": "assets/images/landmark/krung thai.PNG",
      "lat": 14.63250,
      "lng": 121.09556,
      "type": "spot"
    },
    {
      "name": "Miguel & Maria Restaurant",
      "src": "assets/images/landmark/miguel and maria.PNG",
      "lat": 14.64250,
      "lng": 121.10444,
      "type": "spot"
    },
    {
      "name": "Cafe Qizia",
      "src": "assets/images/landmark/cafe and quiza.PNG",
      "lat": 14.64056,
      "lng": 121.10806,
      "type": "spot"
    },
    {
      "name": "Ca Phe Saigon",
      "src": "assets/images/landmark/ca phe saigon.PNG",
      "lat": 14.62611,
      "lng": 121.10250,
      "type": "spot"
    },
    {
      "name": "Fino Deli",
      "src": "assets/images/landmark/fino deli.PNG",
      "lat": 14.64778,
      "lng": 121.11833,
      "type": "spot"
    },
    {
      "name": "Over Easy",
      "src": "assets/images/landmark/over easy.PNG",
      "lat": 14.62861,
      "lng": 121.10200,
      "type": "spot"
    },
    {
      "name": "Tapsi in Vivian",
      "src": "assets/images/landmark/tapsi ni vivian.PNG",
      "lat": 14.62194,
      "lng": 121.10194,
      "type": "spot"
    },
    {"name": "PATODA Tricycle Terminal", "src": "", "lat": 14.6300, "lng": 121.1000, "type": "tricycle"},
    {"name": "Metrobank Tricycle Terminal", "src": "", "lat": 14.6599, "lng": 121.1100, "type": "tricycle"},
    {"name": "PARTODA I Tricycle Terminal", "src": "", "lat": 14.6599, "lng": 121.1100, "type": "tricycle"},
    {"name": "Apitong KAMMI Tricycle Terminal", "src": "", "lat": 14.6305, "lng": 121.1025, "type": "tricycle"},
    {"name": "Katoda Tricycle Terminal - Marikina Heights", "src": "", "lat": 14.6298, "lng": 121.0995, "type": "tricycle"},
    {"name": "Panorama Tricycle Terminal - Marikina Heights", "src": "", "lat": 14.6389, "lng": 121.1256, "type": "tricycle"},
    {"name": "LUMAToda Terminal", "src": "", "lat": 14.6300, "lng": 121.1000, "type": "tricycle"},
    {"name": "Katipunan RK TODA", "src": "", "lat": 14.6320, "lng": 121.1020, "type": "tricycle"},
    {"name": "Concepcion Uno Tricycle Terminal", "src": "", "lat": 14.6500, "lng": 121.1000, "type": "tricycle"},
    {"name": "Terminal near Concepcion Elementary School", "src": "", "lat": 14.6520, "lng": 121.1020, "type": "tricycle"},
    {"name": "Terminal near JEKAI Pharmacy", "src": "", "lat": 14.6540, "lng": 121.1040, "type": "tricycle"},
    {"name": "NEWLILACTODA Tricycle Terminal", "src": "", "lat": 14.6500, "lng": 121.1100, "type": "tricycle"},
    {"name": "Panorama Street Tricycle Terminal", "src": "", "lat": 14.6480, "lng": 121.1080, "type": "tricycle"},
    {"name": "Barangka Tricycle Terminal", "src": "", "lat": 14.6225, "lng": 121.0910, "type": "tricycle"},
    {"name": "Riverbanks Center Tricycle Terminal", "src": "", "lat": 14.6215, "lng": 121.0915, "type": "tricycle"},
    {"name": "Barangka Drive Tricycle Terminal", "src": "", "lat": 14.6240, "lng": 121.0925, "type": "tricycle"},
    {"name": "J.P. Rizal Street Tricycle Terminal", "src": "", "lat": 14.6252, "lng": 121.0965, "type": "tricycle"},
    {"name": "Calumpang Market Tricycle Terminal", "src": "", "lat": 14.6230, "lng": 121.0940, "type": "tricycle"},
    {"name": "Katoda Tricycle Terminal - Calumpang", "src": "", "lat": 14.6245, "lng": 121.0945, "type": "tricycle"},
    {"name": "Tumana Tricycle Terminal", "src": "", "lat": 14.6350, "lng": 121.1000, "type": "tricycle"},
    {"name": "PPCCBB-TODA Tricycle Terminal", "src": "", "lat": 14.6350, "lng": 121.1000, "type": "tricycle"},
    {"name": "Katoda Tricycle Terminal - Tumana", "src": "", "lat": 14.6298, "lng": 121.0997, "type": "tricycle"},
    {"name": "San Roque Tricycle Terminal", "src": "", "lat": 14.6160, "lng": 121.0915, "type": "tricycle"},
    {"name": "Sta. Elena Public Market Terminal", "src": "", "lat": 14.6260, "lng": 121.0895, "type": "tricycle"},
    {"name": "Sta. Elena Barangay Hall Terminal", "src": "", "lat": 14.6235, "lng": 121.0900, "type": "tricycle"},
    {"name": "Maharlika Highway Tricycle Terminal", "src": "", "lat": 14.6245, "lng": 121.0910, "type": "tricycle"},
    {"name": "Sta. Elena Wet Market Terminal", "src": "", "lat": 14.6250, "lng": 121.0890, "type": "tricycle"},
    {"name": "Sta. Elena Covered Court Terminal", "src": "", "lat": 14.6220, "lng": 121.0900, "type": "tricycle"},
    {"name": "Fortune Transport Terminal", "src": "", "lat": 14.6150, "lng": 121.1000, "type": "tricycle"},
    {"name": "Fortune Market Tricycle Terminal", "src": "", "lat": 14.6170, "lng": 121.1020, "type": "tricycle"},
    {"name": "Fortune Barangay Hall Tricycle Terminal", "src": "", "lat": 14.6180, "lng": 121.1030, "type": "tricycle"},
    {"name": "Fortune Covered Court Terminal", "src": "", "lat": 14.6190, "lng": 121.1040, "type": "tricycle"},
    {"name": "Tanong Tricycle Terminal", "src": "", "lat": 14.6180, "lng": 121.0970, "type": "tricycle"},
    {"name": "Katoda Tricycle Terminal - Tanong", "src": "", "lat": 14.6240, "lng": 121.0945, "type": "tricycle"},
    {"name": "Nangka Barangay Hall Terminal", "src": "", "lat": 14.6210, "lng": 121.0925, "type": "tricycle"},
    {"name": "Nangka Covered Court Terminal", "src": "", "lat": 14.6205, "lng": 121.0930, "type": "tricycle"},
    {"name": "Nangka Public Market Terminal", "src": "", "lat": 14.6195, "lng": 121.0935, "type": "tricycle"},
    {"name": "Nangka Elementary School Terminal", "src": "", "lat": 14.6185, "lng": 121.0940, "type": "tricycle"},
    {"name": "Nangka Health Center Terminal", "src": "", "lat": 14.6175, "lng": 121.0945, "type": "tricycle"},
    {"name": "Marikina Sports Center Jeepney Terminal", "src": "", "lat": 14.6505, "lng": 121.1029, "type": "jeepney"},
    {"name": "Panorama (SSS Village) Jeepney Terminal", "src": "", "lat": 14.6480, "lng": 121.0995, "type": "jeepney"},
    {"name": "Horizon Street Jeepney Terminal", "src": "", "lat": 14.6502, "lng": 121.1038, "type": "jeepney"},
    {"name": "Calumpang Jeepney Terminal", "src": "", "lat": 14.6229, "lng": 121.0935, "type": "jeepney"},
    {"name": "BFCT Jeepney Terminal", "src": "", "lat": 14.6315, "lng": 121.1000, "type": "jeepney"},
    {"name": "SM City Marikina Jeepney Terminal", "src": "", "lat": 14.6229, "lng": 121.0915, "type": "jeepney"},
    {"name": "Parang Jeepney Terminal", "src": "", "lat": 14.6390, "lng": 121.1258, "type": "jeepney"}
  ];

  @override
  void initState() {
    super.initState();
    _loadGeoJson();
    _getCurrentLocation();
    _loadCustomMarkerIcon();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();

    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.length > 2) {
      _getPlaceSuggestions(_searchController.text);
    } else {
      setState(() {
        _showSuggestions = false;
        _suggestions = [];
      });
    }
  }
  Future<void> _getPlaceSuggestions(String input) async {
    // Marikina City bounds (using the same coordinates from your boundary)
    // SW corner: 14.6200, 121.0800
    // NE corner: 14.6783, 121.1459
    final bounds = '14.6200,121.0800|14.6783,121.1459';

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
            'input=$input'
            '&key=$_googleApiKey'
            '&locationbias=rectangle:$bounds'
            '&components=country:ph'
    );

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        setState(() {
          _suggestions = List<String>.from(
            data['predictions'].map((prediction) => prediction['description']),
          );
          _showSuggestions = true;
        });
      } else {
        print('API Error: ${data['status']}');
        setState(() {
          _showSuggestions = false;
          _suggestions = [];
        });
      }
    } catch (e) {
      print('Error getting place suggestions: $e');
      setState(() {
        _showSuggestions = false;
        _suggestions = [];
      });
    }
  }
  // Future<void> _getPlaceSuggestions(String input) async {
  //   final url = Uri.parse(
  //     'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$_googleApiKey',
  //   );
  //
  //   try {
  //     final response = await http.get(url);
  //     final data = json.decode(response.body);
  //
  //     if (data['status'] == 'OK') {
  //       setState(() {
  //         _suggestions = List<String>.from(
  //           data['predictions'].map((prediction) => prediction['description']),
  //         );
  //         _showSuggestions = true;
  //       });
  //     }
  //   } catch (e) {
  //     print('Error getting place suggestions: $e');
  //   }
  // }
  Future<void> _searchPlace(String placeName) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?'
            'input=${Uri.encodeComponent(placeName)}'
            '&inputtype=textquery'
            '&fields=geometry,name'
            '&key=$_googleApiKey'
            '&locationbias=rectangle:14.6200,121.0800|14.6783,121.1459'
    );

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'OK' && data['candidates'].isNotEmpty) {
        final location = data['candidates'][0]['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];
        final newPosition = LatLng(lat, lng);

        if (!_IsInsideMarikina(newPosition)) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Outside Marikina"),
              content: Text("The searched location is outside Marikina City boundaries."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            ),
          );
          return;
        }

        final controller = await _mapController.future;
        await controller.animateCamera(CameraUpdate.newLatLngZoom(newPosition, 14));

        setState(() {
          _center = newPosition;
          _markers.add(
            Marker(
              markerId: MarkerId(placeName),
              position: newPosition,
              infoWindow: InfoWindow(title: placeName),
            ),
          );
          _showSuggestions = false;
          selectedLocation = placeName;
        });
      } else {
        print('No results found or API error: ${data['status']}');
      }
    } catch (e) {
      print('Error searching place: $e');
    }
  }
  // Future<void> _searchPlace(String placeName) async {
  //   final url = Uri.parse(
  //     'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=${Uri.encodeComponent(placeName)}&inputtype=textquery&fields=geometry,name&key=$_googleApiKey',
  //   );
  //
  //   try {
  //     final response = await http.get(url);
  //     final data = json.decode(response.body);
  //
  //     if (data['status'] == 'OK' && data['candidates'].isNotEmpty) {
  //       final location = data['candidates'][0]['geometry']['location'];
  //       final lat = location['lat'];
  //       final lng = location['lng'];
  //       final newPosition = LatLng(lat, lng);
  //
  //       final controller = await _mapController.future;
  //       await controller.animateCamera(CameraUpdate.newLatLngZoom(newPosition, 14));
  //
  //       setState(() {
  //         _center = newPosition;
  //         _markers.add(
  //           Marker(
  //             markerId: MarkerId(placeName),
  //             position: newPosition,
  //             infoWindow: InfoWindow(title: placeName),
  //           ),
  //         );
  //         _showSuggestions = false;
  //
  //         // Set this as the selected location for navigation
  //         selectedLocation = placeName;
  //       });
  //     } else {
  //       print('No results found or API error: ${data['status']}');
  //     }
  //   } catch (e) {
  //     print('Error searching place: $e');
  //   }
  // }

  Future<void> _loadGeoJson() async {
    try {
      String data = await rootBundle.loadString('assets/marikina.geojson');
      Map<String, dynamic> jsonData = json.decode(data);
      List<dynamic> coordinates = jsonData["features"][0]["geometry"]["coordinates"][0];

      setState(() {
        marikinaBoundary = coordinates.map((coord) {
          return LatLng(coord[1], coord[0]);
        }).toList();
      });
    } catch (e) {
      print("Error loading GeoJSON: $e");
    }
  }

  void _startRealTimeNavigation() {
    if (_currentLocation == null || selectedLocation == null) return;

    setState(() {
      _isNavigating = true;
      _routeSteps = [];
      _currentStepIndex = 0;
      _currentInstruction = "";
    });

    final location = Location();
    _locationSubscription = location.onLocationChanged.listen((LocationData currentLocation) {
      if (!_isNavigating) return;

      setState(() {
        _currentLocationData = currentLocation;
        _currentLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);
      });

      // Update current step
      _updateCurrentStep(currentLocation);

      // Update camera to follow user
      _updateCameraPosition(currentLocation.heading ?? 0);

      // Periodically update the route
      if (_lastRouteUpdate == null || DateTime.now().difference(_lastRouteUpdate!).inSeconds > 30) {
        _getRoute();
        _lastRouteUpdate = DateTime.now();
      }
    });
  }

  void _updateCameraPosition(double bearing) {
    if (_currentLocation != null) {
      // Ensure camera stays within Marikina
      final boundedLat = _currentLocation!.latitude.clamp(14.6200, 14.6783);
      final boundedLng = _currentLocation!.longitude.clamp(121.0800, 121.1459);
      final boundedLocation = LatLng(boundedLat, boundedLng);

      mapController.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: boundedLocation,
            zoom: _isNavigating ? 26.0 : _cameraZoom,
            tilt: _isNavigating  ? 50 : _cameraTilt,
            bearing: bearing,
          ),
        ),
      );
    }
  }

  void _stopNavigation() {
    setState(() {
      _isNavigating = false;
      _polylines.clear();
      _distanceText = null;
      _durationText = null;
      _routeCoords = [];
      _routeSteps = [];
      _currentInstruction = "";
    });
    _locationSubscription?.cancel();
  }

  Future<void> _getRoute() async {
    if (!_isNavigating || _currentLocation == null || selectedLocation == null) return;

    var destination = locations.firstWhere((loc) => loc["name"] == selectedLocation, orElse: () => {});
    double destLat, destLng;

    if (destination.isNotEmpty) {
      destLat = destination["lat"];
      destLng = destination["lng"];
    } else {
      Marker? searchedMarker = _markers.firstWhere((marker) => marker.infoWindow.title == selectedLocation, orElse: () => null!);
      if (searchedMarker == null) return;
      destLat = searchedMarker.position.latitude;
      destLng = searchedMarker.position.longitude;
    }

    String url = "https://maps.googleapis.com/maps/api/directions/json"
        "?origin=${_currentLocation!.latitude},${_currentLocation!.longitude}"
        "&destination=$destLat,$destLng"
        "&mode=driving"
        "&key=$_googleApiKey";

    String _parseDirection(String instruction, String? maneuver) {
      // First clean HTML tags and extract just the street names
      instruction = instruction.replaceAll(RegExp(r'<[^>]*>'), '');

      // Extract the main street name (everything before "toward" if it exists)
      String streetName = instruction.split(' toward ').first;

      // Handle based on maneuver if available
      switch (maneuver?.toLowerCase()) {
        case 'turn-right':
        case 'sharp-right':
          return '$streetName';
        case 'turn-left':
        case 'sharp-left':
          return '$streetName';
        case 'straight':
          return '$streetName';
        case 'merge':
          return '$streetName';
        case 'fork-right':
          return '$streetName';
        case 'fork-left':
          return '$streetName';
        case 'ramp-right':
          return '$streetName';
        case 'ramp-left':
          return '$streetName';
        case 'uturn-right':
        case 'uturn-left':
          return '$streetName';
        default:
        // For compass directions, just show the street name with basic direction
          if (instruction.toLowerCase().contains('southwest') ||
              instruction.toLowerCase().contains('southeast') ||
              instruction.toLowerCase().contains('east')) {
            return 'Go right on $streetName';
          } else if (instruction.toLowerCase().contains('northwest') ||
              instruction.toLowerCase().contains('northeast') ||
              instruction.toLowerCase().contains('west')) {
            return 'Turn left on $streetName';
          } else {
            return 'Stright Ahead $streetName';
          }
      }
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (_isNavigating && data["routes"].isNotEmpty) {
          var route = data["routes"][0];
          var legs = route["legs"][0];


          List<Map<String, dynamic>> steps = [];
          for (var step in legs["steps"]) {
            // Extract street name if available
            String streetName = '';
            if (step["html_instructions"] != null) {
              streetName = step["html_instructions"].toString()
                  .replaceAll(RegExp(r'<[^>]*>'), '')
                  .replaceAll(RegExp(r'Head [a-z]+'), '')
                  .trim();
            }

            steps.add({
              'instruction': _parseDirection(
                streetName.isNotEmpty ? streetName : 'the road',
                step["maneuver"]?.toString(),
              ),
              'distance': step["distance"]["text"],
              'duration': step["duration"]["text"],
              'start_location': LatLng(
                  step["start_location"]["lat"],
                  step["start_location"]["lng"]
              ),
              'end_location': LatLng(
                  step["end_location"]["lat"],
                  step["end_location"]["lng"]
              ),
              'polyline': _decodePolyline(step["polyline"]["points"])
            });
          }

          setState(() {
            _distanceText = legs["distance"]["text"];
            _durationText = legs["duration"]["text"];
            _routeCoords = _decodePolyline(route["overview_polyline"]["points"]);
            _routeSteps = steps;
            _currentStepIndex = 0;
            _currentInstruction = steps.isNotEmpty ? steps[0]['instruction'] : "";
            _nextInstruction = steps.length > 1 ? steps[1]['instruction'] : "You have arrived";

            _polylines.clear();
            if (_isNavigating) {
              _polylines.add(Polyline(
                polylineId: PolylineId("route"),
                points: _routeCoords,
                color: Colors.blue,
                width: 8,
                geodesic: true,
              ));
            }

            if (_routeCoords.isNotEmpty && _isNavigating) {
              mapController.animateCamera(
                CameraUpdate.newLatLngBounds(boundsFromLatLngList(_routeCoords), 100),
              );
            }
          });
        }
      }
    } catch (e) {
      print("Error getting route: $e");
    }
  }
  void _updateCurrentStep(LocationData currentLocation) {
    if (_routeSteps.isEmpty) return;

    final currentLatLng = LatLng(currentLocation.latitude!, currentLocation.longitude!);

    for (int i = 0; i < _routeSteps.length; i++) {
      final step = _routeSteps[i];
      final distance = _calculateDistance(
          currentLatLng.latitude,
          currentLatLng.longitude,
          step['end_location'].latitude,
          step['end_location'].longitude
      );

      if (distance < 50) { // Within 50 meters of step's end point
        setState(() {
          _currentStepIndex = i;
          _currentInstruction = _routeSteps[i]['instruction'];
          _nextInstruction = (i + 1 < _routeSteps.length)
              ? _routeSteps[i + 1]['instruction']
              : "You have arrived";
        });
        break;
      }
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p)/2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a)) * 1000; // in meters
  }
  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }

  Future<void> _getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    var userLocation = await location.getLocation();
    setState(() {
      _currentLocation = LatLng(userLocation.latitude!, userLocation.longitude!);
    });
    _updateCameraPosition(userLocation.heading ?? 0);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _mapController.complete(controller);
    bool _isTrafficEnabled = true;
    mapController.setMapStyle('''
  [
    /* DISABLE ALL LABELS GLOBALLY */
    {
      "featureType": "all",
      "elementType": "labels",
      "stylers": [{"visibility": "off"}]
    },
    
    /* ENABLE ONLY MARIKINA STREETS */
    {
      "featureType": "road",
      "elementType": "labels.text",
      "stylers": [{
        "visibility": "off",
        "color": "#000000",
        "lightness": 40
      }],
      "geometry": {
        "within": {
          "polygon": {
            "coordinates": [[
              [121.0800, 14.6200],  // SW corner
              [121.1459, 14.6200],  // SE corner
              [121.1459, 14.6783],  // NE corner
              [121.0800, 14.6783],  // NW corner
              [121.0800, 14.6200]   // Close polygon
            ]]
          }
        }
      }
    }
  ]
  ''');
    _updateCameraPosition(0);
    _addMarikinaBoundaryLayer();
  }

  void _addMarikinaBoundaryLayer() {
    polygons.add(Polygon(
      polygonId: PolygonId("marikina_boundary"),
      points: marikinaBoundary,
      strokeWidth: 2,
      strokeColor: Colors.blue.withOpacity(0.5),
      fillColor: Colors.blue.withOpacity(0.15),
    ));
  }

  void _onMarkerTapped(String name) {
    setState(() {
      selectedLocation = name;
      isOverlayVisible = true;
    });
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  void _startNavigation() {
    if (selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a destination.")),
      );
      return;
    }

    // Find the destination coordinates
    LatLng? destination;
    var location = locations.firstWhere(
            (loc) => loc["name"] == selectedLocation,
        orElse: () => {}
    );

    if (location.isNotEmpty) {
      destination = LatLng(location["lat"], location["lng"]);
    } else {
      Marker? searchedMarker = _markers.firstWhere(
              (marker) => marker.infoWindow.title == selectedLocation,
          orElse: () => null!
      );
      if (searchedMarker != null) {
        destination = searchedMarker.position;
      }
    }

    if (destination == null) return;

    // Check if destination is within Marikina
    if (!_IsInsideMarikina(destination)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Outside Marikina"),
          content: Text("The selected location is outside Marikina City boundaries."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    if (_isNavigating) {
      _stopNavigation();
    } else {
      // Clear any existing route before starting new navigation
      setState(() {
        _polylines.clear();
        _routeCoords = [];
      });
      _startRealTimeNavigation();
      _getRoute();

      // Reset camera to default navigation view
      if (_currentLocation != null) {
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentLocation!,
              zoom: 16,
              tilt: 50,
            ),
          ),
        );
      }
    }
  }
  Widget _buildSuggestionsList() {
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        if (_suggestions.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20, 15, 20, 10),
                child: Text(
                  'Search Results',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
              ),
              ..._suggestions.map((suggestion) => ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                title: Text(suggestion),
                onTap: () {
                  _searchController.text = suggestion;
                  _searchPlace(suggestion);
                  setState(() => _showSuggestions = false);
                },
              )).toList(),
            ],
          ),
        if (_searchController.text.isEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20, 15, 20, 10),
                child: Text(
                  'Popular Marikina Locations',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
              ),
              ...locations.map((location) => ListTile(
                leading: Icon(Icons.location_on, color: primaryColor),
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
                title: Text(location['name']),
                onTap: () => _selectPopularLocation(location),
              )).toList(),
            ],
          ),
      ],
    );
  }

// Add this helper method
  void _selectPopularLocation(Map<String, dynamic> location) {
    setState(() {
      selectedLocation = location['name'];
      _searchController.clear();
      _showSuggestions = false;
      _suggestions = [];
      _searchFocusNode.unfocus();
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(location['lat'], location['lng']),
          16,
        ),
      );
      _markers.add(
        Marker(
          markerId: MarkerId(location['name']),
          position: LatLng(location['lat'], location['lng']),
          infoWindow: InfoWindow(title: location['name']),
        ),
      );
    });
  }
  void _closeOverlay() {
    setState(() => isOverlayVisible = false);
  }

  bool _isInsideMarikina(double lat, double lng) {
    return lat >= 14.6200 && lat <= 14.6783 && lng >= 121.0800 && lng <= 121.1459;
  }

  bool _IsInsideMarikina(LatLng position) {
    return position.latitude >= 14.6200 &&
        position.latitude <= 14.6783 &&
        position.longitude >= 121.0800 &&
        position.longitude <= 121.1459;
  }

  String? _getImagePathForSelectedLocation() {
    if (selectedLocation == null) return null;
    try {
      return locations.firstWhere((loc) => loc["name"] == selectedLocation)["src"];
    } catch (e) {
      return null;
    }
  }

  String? _getNameForSelectedLocation() {
    if (selectedLocation == null) return null;
    try {
      return locations.firstWhere((loc) => loc["name"] == selectedLocation)["name"];
    } catch (e) {
      return null;
    }
  }

  BitmapDescriptor? tricycleIcon;
  BitmapDescriptor? jeepneyIcon;

  Future<void> _loadCustomMarkerIcon() async {
    try {
      // Load tricycle icon
      final tricycleData = await rootBundle.load('assets/images/tricycle.png');
      final jeepData  = await rootBundle.load('assets/images/jeepney.png');

      final tricycleBytes = tricycleData.buffer.asUint8List();
      final jeepBytes = jeepData.buffer.asUint8List();

      final tricycleCodec = await instantiateImageCodec(
        tricycleBytes,
        targetWidth: 60,
        targetHeight: 60,
      );

      final jeepCodec = await instantiateImageCodec(
        jeepBytes,
        targetWidth: 60,
        targetHeight: 60,
      );

      final tricycleFrame = await tricycleCodec.getNextFrame();
      final jeepFrame = await jeepCodec.getNextFrame();

      final tricycleResized = await tricycleFrame.image.toByteData(
        format: ImageByteFormat.png,
      );
      final jeepResized = await jeepFrame.image.toByteData(
        format: ImageByteFormat.png,
      );

      if (tricycleResized != null) {
        tricycleIcon = BitmapDescriptor.fromBytes(tricycleResized.buffer.asUint8List());
      }
      if  (jeepResized != null){
        jeepneyIcon = BitmapDescriptor.fromBytes(jeepResized.buffer.asUint8List());
      }
    } catch (e) {
      print('Error loading custom icons: $e');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = {};
    Set<Polygon> polygons = {};

    if (marikinaBoundary.isNotEmpty) {
      markers = locations.where((loc) => _isInsideMarikina(loc["lat"], loc["lng"]))
          .map((loc) {

        final BitmapDescriptor icon;
        if (loc["type"] == "tricycle" && tricycleIcon != null) {
          icon = tricycleIcon!;
        }else if(loc["type"] == "jeepney" && jeepneyIcon != null){
          icon = jeepneyIcon!;
        }else {
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);

        }

        return Marker(
          markerId: MarkerId(loc["name"]),
          position: LatLng(loc["lat"], loc["lng"]),
          icon: icon,
          onTap: () => _onMarkerTapped(loc["name"]),
        );
      }).toSet();

      // Add searched markers
      markers.addAll(_markers);

      polygons.addAll([
        Polygon(
          polygonId: PolygonId("marikina"),
          points: marikinaBoundary,
          strokeWidth: 3,
          strokeColor: Colors.black,
          fillColor: Colors.transparent,
        ),
        Polygon(
          polygonId: PolygonId("outside"),
          points: [
            LatLng(15.0000, 120.8000),
            LatLng(15.0000, 121.5000),
            LatLng(14.4000, 121.5000),
            LatLng(14.4000, 120.8000),
          ],
          holes: [marikinaBoundary],
          strokeWidth: 0,
          fillColor: Colors.blueAccent.withOpacity(1),
        ),
      ]);
    }

      return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _searchFocusNode.unfocus();
            setState(() {
              _showSuggestions = false;
            });
          },
    child: Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            onTap: (LatLng position) {
              if (_searchFocusNode.hasFocus) {
                _searchFocusNode.unfocus();
                setState(() => _showSuggestions = false);
              }
            },
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(14.5995, 120.9842),
              zoom: 15,
              tilt: _cameraTilt,
            ),
            markers: markers,
            trafficEnabled: true,
            polylines: _polylines,
            polygons: polygons,
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            myLocationEnabled: true,
            mapType: MapType.normal,
            minMaxZoomPreference: MinMaxZoomPreference(14, 20),
          ),

          // Navigation info panel
          // Add this to your Stack children in build()
          if (_isNavigating && _currentInstruction.isNotEmpty)
            Positioned(
              bottom: 80, // Above the navigation button
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current instruction
                    Text(
                      _currentInstruction,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "${_routeSteps[_currentStepIndex]['distance']} • ${_routeSteps[_currentStepIndex]['duration']}",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),

                    // Divider
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1, color: Colors.grey[300]),
                    ),

                    // Next instruction
                    Text(
                      "Next: $_nextInstruction",
                      style: TextStyle(fontSize: 16, color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),
            ),
          // In your build method, replace the Positioned widget containing the search bar with this:
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Search bar with improved styling
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(30),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          focusNode: _searchFocusNode,
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search places in Marikina...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.search, color: primaryColor),
                              onPressed: () {
                                if (_searchController.text.isNotEmpty) {
                                  _searchPlace(_searchController.text);
                                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                                }
                              },
                            ),
                          ),
                          onChanged: (value) => _onSearchChanged(),
                          onTap: () => setState(() => _showSuggestions = true),
                        ),
                      ),
                      SizedBox(width: 10),
                      // Current location button with better visual feedback
                      Tooltip(
                        message: 'Current Location',
                        child: Material(
                          elevation: 2,
                          shape: CircleBorder(),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: _getCurrentLocation,
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.my_location,
                                  color: primaryColor, size: 28),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Suggestions list with improved styling
                if (_showSuggestions && !_isNavigating)
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: _buildSuggestionsList(),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: 5,
            left: 5,
            right: 5,
            child: Column(
              children: [
                if (_isNavigating && _distanceText != null && _durationText != null)
                  Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(15),

                  ),
                SizedBox(height: 10),
                // Modified button to be full width
                SizedBox(
                  width: double.infinity, // Makes the button take full width
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(10),
                    color: _isNavigating ? warningColor : primaryColor,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: _startNavigation,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isNavigating ? Icons.stop : Icons.directions,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Text(
                              _isNavigating ? 'STOP NAVIGATION' : 'START NAVIGATION',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Image overlay
          if (isOverlayVisible && selectedLocation != null)
            AnimatedOpacity(
              opacity: isOverlayVisible ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: GestureDetector(
                onTap: _closeOverlay,
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: _getImagePathForSelectedLocation() != null
                          ? Stack(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.height * 0.7,
                            padding: EdgeInsets.all(20),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                _getImagePathForSelectedLocation()!,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Text(
                                    _getNameForSelectedLocation() ?? 'Image not available',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 40,
                            right: 40,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.white, size: 30),
                              onPressed: _closeOverlay,
                            ),
                          ),
                        ],
                      )
                          : Center(
                        child: Text(
                          _getNameForSelectedLocation() ?? 'Image not available',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
    );
  }
}