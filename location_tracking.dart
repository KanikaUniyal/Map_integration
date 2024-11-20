import 'dart:math';
import 'package:driveCo/src/app_configs/app_colors.dart';
import 'package:driveCo/src/app_configs/app_images.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LocationSharing(),
    );
  }
}

class LocationSharing extends StatefulWidget {
  const LocationSharing({super.key});

  @override
  State<LocationSharing> createState() => _LocationSharingState();
}


class _LocationSharingState extends State<LocationSharing> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(37.7749, -122.4194);
  bool _isLoadingLocation = true;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }



  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }


    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _isLoadingLocation = false;
      _markers.add(Marker(
        markerId: const MarkerId('current_location'),
        position: _currentPosition,
        infoWindow: InfoWindow(title: 'You are here'),
      ));


      _addPolyline();
    });

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition, zoom: 14.0),
      ),
    );
  }


  LatLng getNearbyLocation(LatLng originalLocation, double range) {
    final random = Random();
    double latOffset = (random.nextDouble() * range) - (range / 2);
    double lngOffset = (random.nextDouble() * range) - (range / 2);

    return LatLng(
      originalLocation.latitude + latOffset,
      originalLocation.longitude + lngOffset,
    );
  }


  void _addPolyline() {
    final List<LatLng> _nearbyLocations = [
      getNearbyLocation(_currentPosition, 0.01),
      getNearbyLocation(_currentPosition, 0.01),
      getNearbyLocation(_currentPosition, 0.01),
    ];


    _polylines.add(Polyline(
      polylineId: const PolylineId('route'),
      points: [_currentPosition, ..._nearbyLocations],
      color: Colors.indigo,
      width: 5,
      patterns: [PatternItem.dot, PatternItem.gap(5)],
    ));
  }

  void _centerOnLocation() {
    if (_mapController != null) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition, zoom: 14.0),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Stack(
        children: [
          // Google Map
          _isLoadingLocation
              ? const Center(child: CircularProgressIndicator())
              : ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: 0.6,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentPosition,
                  zoom: 14.0,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                markers: _markers,
                polylines: _polylines,
              ),
            ),
          ),

          Positioned(
            top: 20.0,
            left: 16.0,
            child: IconButton(
              icon: Image.asset(
                AppImages.arrowBack,
                color: AppColors.primaryTextColor,
                width: 32,
                height: 32,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).size.height / 3,
            right: 16.0,
            child: FloatingActionButton(
              shape: const CircleBorder(),
              backgroundColor: Colors.white,
              onPressed: _centerOnLocation,
              child: Image.asset(
                AppImages.geofence,
                color: AppColors.primaryTextColor,
              ),
            ),
          ),

          Positioned(
            top: (MediaQuery.of(context).size.height / 3) + 70.0,
            right: 16.0,
            child: GestureDetector(
              onTap: () {
                // Your action
              },
              child: Image.asset(
                AppImages.arrow,
                width: 70.0,
              ),
            ),
          ),

          Positioned(
            top: 30.0,
            left: MediaQuery.of(context).size.width / 2 - 60.0,
            child: Stack(
              children: [
                Image.asset(
                  AppImages.rect,
                  width: 139.0,
                  height: 45.0,
                ),
                Positioned(
                  left: 25.0,
                  top: 3.5,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        AppImages.circl,
                        width: 27.0,
                        height: 27.0,
                      ),
                      Positioned(
                        child: Image.asset(
                          AppImages.park,
                          width: 15.0,
                          height: 15.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 60.0,
                  top: 14.0,
                  child: Text(
                    'Parked',
                    style: GoogleFonts.inter(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      height: 16.94 / 40,
                      textStyle: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 300.0, // Fixed height
              margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 3.0),
              padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10.0,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Image.asset(
                      AppImages.grey,
                      width: 80.0,
                      height: 3.0,
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(AppImages.jeepImage),
                          radius: 20.0,
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "John's car",
                                  style: GoogleFonts.inter(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4.0),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              "25.5km",
                              style: GoogleFonts.inter(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryTextColor,
                              ),
                            ),
                            Text(
                              "Distance covered",
                              style: GoogleFonts.inter(
                                fontSize: 12.0,
                                color: AppColors.outlineBorderColor,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Image.asset(
                            AppImages.lin,
                            height: 40.0,
                            width: 2.0,
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              "25 min",
                              style: GoogleFonts.inter(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryTextColor,
                              ),
                            ),
                            Text(
                              "Avg time",
                              style: GoogleFonts.inter(
                                fontSize: 12.0,
                                color: AppColors.outlineBorderColor,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Image.asset(
                            AppImages.lin,
                            height: 40.0,
                            width: 1.0,
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              "10.5 km",
                              style: GoogleFonts.inter(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryTextColor,
                              ),
                            ),
                            Text(
                              "Distance from you",
                              style: GoogleFonts.inter(
                                fontSize: 12.0,
                                color: AppColors.outlineBorderColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 22.0),


                    Row(
                      children: [
                        Image.asset(
                          AppImages.location,
                          color: Colors.blue[900],
                          width: 20.0,
                          height: 20.0,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            "70, Canton Township, Washington County, Pennsylvania, 15301, USA",
                            style: GoogleFonts.inter(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 19.0),


                    Row(
                      children: [
                        SizedBox(
                          width: 150, // width
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 60),
                              backgroundColor: Colors.blue[100],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppImages.ignition,
                                  color: Colors.blue[900],
                                  width: 16.0,
                                  height: 16.0,
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  "Ignition off",
                                  style: GoogleFonts.inter(
                                    color: Colors.blue[900],
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        SizedBox(
                          width: 200, //  width
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 60),
                              backgroundColor: Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: Text(
                              "No harsh event detect",
                              style: GoogleFonts.inter(
                                color: AppColors.primaryTextColor,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
