import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps/token.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_google_maps/signIn.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
void main() {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(
    MaterialApp(
      home: LoginPage(), // Đây là trang chạy đầu tiên
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

//Chức năng lấy giá
Future<double?> getPrice(double? Distance) async {
  final response = await http.get(
    Uri.parse('https://10.0.2.2:7145/api/Price/GetPrice'),
    headers: {
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    // Lấy giá tiền từ data
    if (Distance != null) {
      if (Distance > 1.0) {
        final double price = data['price'] * Distance;
        return price;
      } else {
        final double? pricelow = double.tryParse(data['priceLow'].toString());
        return pricelow;
      }
    } else {
      return 0;
    }
  } else {
    return 0;
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController _originController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();
  String distance = "";
  String time = "";
  double? price = 0;
  int id = 0;
  bool showRouteDetails = false;
  final String key = 'AIzaSyDQ2c_pOSOFYSjxGMwkFvCVWKjYOM9siow';

  Set<Marker> _markers = Set<Marker>();
  Set<Polygon> _polygons = Set<Polygon>();
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polygonLatLngs = <LatLng>[];
//Chức năng thông báo
Future<void> showNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    '1'    
    '12', // Thay đổi thành ID kênh thông báo của bạn
    'HutechDriver', // Thay đổi thành tên kênh thông báo của bạn
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
    icon: '@mipmap/ic_launcher',
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    1, // ID thông báo, có thể đặt là một giá trị duy nhất
    'Chuyến đi của bạn',
    'Đặt xe thành công. Nhấn để xem chi tiết chuyến đi.',
    platformChannelSpecifics,
    payload: 'payload', // Dữ liệu bạn muốn gửi khi người dùng nhấn vào thông báo
  );
  void _initialize() {
  final InitializationSettings initializationSettings =
      InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'));

}

MyApp() {
  _initialize();
}

}  
//Giải mã
  Map<String, dynamic> decodedToken = json.decode(
    String.fromCharCodes(
      base64Url.decode(TokenManager.getToken().split('.')[1]),
    ),
  );
//Chức năng booking
  Future<void> booking() async {
    final Map<String, dynamic> data = {
      'UserId': id,
      'distance': distance,
      'time': time,
      'startLocation': _originController.text,
      'endLocation': _destinationController.text,
      'price': price,
    };
    final response = await http.post(
      Uri.parse('https://10.0.2.2:7145/api/Trip/Booking'),
      body: jsonEncode(data), // Chuyển đổi dữ liệu thành JSON
      headers: {
        'Content-Type':
            'application/json', // Đặt header Content-Type thành application/json
      },
    );

    if (response.statusCode == 200) {
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Đặt xe thành công'),
        content: Text('Chuyến đi của bạn sẽ được nhận sớm nhất có thể. Vui lòng đợi.'),
      );
    },
  );
    showNotification();
    } else {
      debugPrint("Error: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");
    }
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final latLng in list) {
      if (latLng.latitude < minLat) {
        minLat = latLng.latitude;
      }
      if (latLng.latitude > maxLat) {
        maxLat = latLng.latitude;
      }
      if (latLng.longitude < minLng) {
        minLng = latLng.longitude;
      }
      if (latLng.longitude > maxLng) {
        maxLng = latLng.longitude;
      }
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void updatePolylines(List<LatLng> points) {
    setState(() {
      _polylines.clear();
      _polylines.add(Polyline(
        polylineId: PolylineId('route'),
        points: points,
        color: Colors.green,
        width: 5,
      ));
    });
  }

  int _polygonIdCounter = 1;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(10.776889, 106.700897),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();

    _setMarker(LatLng(10.776889, 106.700897));
  }

  void _setMarker(LatLng point) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('marker'),
          position: point,
        ),
      );
    });
  }

  void _setPolygon() {
    final String polygonIdVal = 'polygon_$_polygonIdCounter';
    _polygonIdCounter++;

    _polygons.add(
      Polygon(
        polygonId: PolygonId(polygonIdVal),
        points: polygonLatLngs,
        strokeWidth: 2,
        fillColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('Google Maps'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          GoogleMap(
            mapType: MapType.normal,
            markers: _markers,
            polygons: _polygons,
            polylines: _polylines,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onTap: (point) {
              setState(() {
                polygonLatLngs.add(point);
                _setPolygon();
              });
            },
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                GooglePlaceAutoCompleteTextField(
                  googleAPIKey: 'AIzaSyDQ2c_pOSOFYSjxGMwkFvCVWKjYOM9siow',
                  textEditingController: _originController,
                  countries: ["vn"],
                  inputDecoration: InputDecoration(
                    labelText: '  Điểm đi',
                  ),
                  debounceTime: 800,
                  itemClick: (Prediction prediction) {
                    setState(() {
                      _originController.text = prediction.description ?? "";
                      _originController.selection = TextSelection.fromPosition(
                          TextPosition(
                              offset: prediction.description?.length ?? 0));
                    });
                  },
                  itemBuilder: (context, index, Prediction prediction) {
                    return Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Icon(Icons.location_on),
                          SizedBox(
                            width: 7,
                          ),
                          Expanded(
                              child: Text("${prediction.description ?? ""}"))
                        ],
                      ),
                    );
                  },
                  seperatedBuilder: Divider(),
                  isCrossBtnShown: true,
                ),
                GooglePlaceAutoCompleteTextField(
                  googleAPIKey: 'AIzaSyDQ2c_pOSOFYSjxGMwkFvCVWKjYOM9siow',
                  textEditingController: _destinationController,
                  countries: ["vn"],
                  inputDecoration: InputDecoration(
                    labelText: '  Điểm đến',
                  ),
                  debounceTime: 800,
                  isLatLngRequired: false,
                  getPlaceDetailWithLatLng: (Prediction prediction) {
                    print("placeDetails" + prediction.lat.toString());
                  },
                  itemClick: (Prediction prediction) {
                    setState(() {
                      _destinationController.text =
                          prediction.description ?? "";
                      _destinationController.selection =
                          TextSelection.fromPosition(TextPosition(
                              offset: prediction.description?.length ?? 0));
                    });
                  },
                  itemBuilder: (context, index, Prediction prediction) {
                    return Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Icon(Icons.location_on),
                          SizedBox(
                            width: 7,
                          ),
                          Expanded(
                              child: Text("${prediction.description ?? ""}"))
                        ],
                      ),
                    );
                  },
                  seperatedBuilder: Divider(),
                  isCrossBtnShown: true,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: FloatingActionButton(
                      onPressed: () async {
                        String origin = _originController.text;
                        String destination = _destinationController.text;
                        // Chuyển đổi tên địa điểm thành tọa độ
                        List<Location> originLocations =
                            await locationFromAddress(origin);
                        List<Location> destinationLocations =
                            await locationFromAddress(destination);

                        if (originLocations.isNotEmpty &&
                            destinationLocations.isNotEmpty) {
                          // Lấy tọa độ từ danh sách kết quả
                          final originLocation = originLocations.first;
                          final destinationLocation =
                              destinationLocations.first;

                          var polylinePoints = PolylinePoints();
                          PolylineResult result =
                              await polylinePoints.getRouteBetweenCoordinates(
                            key, // Thay bằng API Key của bạn
                            PointLatLng(originLocation.latitude,
                                originLocation.longitude), // Tọa độ điểm đi
                            PointLatLng(
                                destinationLocation.latitude,
                                destinationLocation
                                    .longitude), // Tọa độ điểm đến
                            travelMode: TravelMode
                                .driving, // Hoặc sử dụng travelMode tùy chọn
                          );

                          if (result.points.isNotEmpty) {
                            List<LatLng> routeCoords = result.points
                                .map((point) =>
                                    LatLng(point.latitude, point.longitude))
                                .toList();
                            updatePolylines(routeCoords);
                            LatLngBounds bounds =
                                boundsFromLatLngList(routeCoords);
                            // Tạo một CameraUpdate để di chuyển và zoom bản đồ đến khu vực tuyến đường
                            CameraUpdate cameraUpdate =
                                CameraUpdate.newLatLngBounds(
                                    bounds, 100); // 50 là padding cho phần biên
                            showRouteDetails = true;
                            time = result.duration.toString();
                            String userId = decodedToken['Id'];
                            id = int.parse(userId);
                            distance = result.distance.toString();
                            // Xóa các ký tự không phải là số hoặc dấu chấm
                            String distanceNumber =
                                distance.replaceAll(RegExp(r'[^0-9.]'), '');

                            double? distanceTest =
                                double.tryParse(distanceNumber);
                            if (distanceTest != null) {
                              double? newPrice = await getPrice(distanceTest);
                              setState(() {
                                price = newPrice;
                              });
                            }

                            // Sử dụng GoogleMapController để thực hiện CameraUpdate
                            final GoogleMapController controller =
                                await _controller.future;
                            controller.animateCamera(cameraUpdate);
                            _markers.clear();
                            _markers.add(Marker(
                              markerId: MarkerId('destination'),
                              position: LatLng(destinationLocation.latitude,
                                  destinationLocation.longitude),
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueRed),
                            ));
                          }
                        }
                      },
                      child: Text(
                        'Show Route',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showRouteDetails == true)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 200,
                color: Colors.grey[200],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Distance: $distance'),
                    Text('Time: $time'),
                    Text('Price: $price đ'),
                    Text('Id: ${id.toString()}'),
                    ElevatedButton(
                      onPressed: booking,
                      child: Text('Đặt xe'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showRouteDetails = false;
                        });
                      },
                      child: Text('Quay lại'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
