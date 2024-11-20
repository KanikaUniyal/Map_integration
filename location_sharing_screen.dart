import 'dart:async';
import 'package:driveCo/src/Location_sharing/Location_moving.dart';
import 'package:driveCo/src/Location_sharing/custom_google_map_locationsharing.dart';
import 'package:driveCo/src/app_configs/app_colors.dart';
import 'package:driveCo/src/app_configs/app_images.dart';
import 'package:driveCo/src/common_widgets/buttons/primary_button.dart';
import 'package:driveCo/src/constants/app_sizes.dart';
import 'package:driveCo/src/features/geofence/provider/geofence_provider.dart';
import 'package:driveCo/src/utils/string_hardcoded_ext.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class ShareLocationScreen extends StatefulWidget {
  const ShareLocationScreen({super.key});

  @override
  State<ShareLocationScreen> createState() => _ShareLocationScreenState();
}

class _ShareLocationScreenState extends State<ShareLocationScreen> {
  // final TextEditingController _addressController = TextEditingController();
  Timer? _debounce;
  LatLng? _currentShareLocation;
  LatLng? _destinationLocation;
  Set<Polyline> _polylines = {};

  final GlobalKey<CustomLocationSharingMapState> _mapStateKey = GlobalKey<
      CustomLocationSharingMapState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GeofenceProvider>(context, listen: false)
          .fetchInitialLocation(context);
    });
  }

  @override
  void dispose() {
    // _addressController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Method to draw polyline between current location and destination
  void _drawRoute(LatLng start, LatLng end) {
    Polyline polyline = Polyline(
      polylineId: const PolylineId('route'),
      points: [start, end], // Simple line between the two points
      width: 5,
      color: Colors.blue,
    );

    setState(() {
      _polylines = {polyline};
    });
  }

  Future<void> _onSuggestionSelected(String suggestion) async {
    final provider = context.read<GeofenceProvider>();
    final placeId = provider.getPlaceIdFromDescription(suggestion);
    final latLng = await provider.fetchPlaceDetails(placeId);
    if (latLng != null) {
      setState(() {
        _currentShareLocation = latLng;
        // _addressController.text = suggestion;
        provider.clearSuggestions();
      });


      _destinationLocation = LatLng(latLng.latitude + 0.01, latLng.longitude + 0.01);


      if (_currentShareLocation != null && _destinationLocation != null) {
        _drawRoute(_currentShareLocation!, _destinationLocation!);
      }


      _mapStateKey.currentState?.updateMarkerPosition(latLng);
    }
  }

  void _centerOnLocation() {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            // Google Map Positioned on the screen
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomLocationSharingMap(
                key: _mapStateKey,
                onLocationUpdated: (location) {
                  setState(() {
                    _currentShareLocation = location;
                  });
                },
                polylines: _polylines,
              ),
            ),

            // Back arrow Positioned at the top left
            Positioned(
              top: 90.0,
              left: 16.0,
              child: IconButton(
                icon: Image.asset(
                  AppImages.arrowBack,
                  color: AppColors.primaryTextColor,
                  width: 42,
                  height: 42,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),

            // FloatingActionButton to center on location
            Positioned(
              top: (MediaQuery.of(context).size.height / 3) + 115.0,
              right: 16.0,
              child: FloatingActionButton(
                shape: const CircleBorder(),
                backgroundColor: Colors.white,
                onPressed: _centerOnLocation,
                child: Image.asset(
                  AppImages.geofence,
                  color: Colors.black,
                ),
              ),
            ),


            Positioned(
              top: (MediaQuery.of(context).size.height / 3) + 190.0,
              right: 16.0,
              child: GestureDetector(
                onTap: () {
                  // Your action for moving between locations
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => LocationMovingScreen(), // Replace with your next screen widget
                 ),
                 );
                },
                child: Image.asset(
                  AppImages.arrow,
                  width: 70.0,
                ),
              ),
            ),

            // Rectangular element with Parked text at the center of the screen
            Positioned(
              top: 100.0,
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
                width: MediaQuery.of(context).size.width,
                height: 300.0,
                // Fixed height
                margin: const EdgeInsets.symmetric(
                    horizontal: 0.0, vertical: 0.0),
                padding: const EdgeInsets.symmetric(
                    vertical: 25.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18.0),
                    topRight: Radius.circular(18.0),
                    bottomLeft: Radius.circular(0.0),
                    bottomRight: Radius.circular(0.0),
                  ),
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
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0),
                            child: Container(
                              height: 40.0,
                              width: 2.0,
                              color: Colors.grey,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                "25min",
                                style: GoogleFonts.inter(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0),
                            child: Container(
                              height: 40.0,
                              width: 2.0,
                              color: Colors.grey,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                "10.5km",
                                style: GoogleFonts.inter(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
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
                      const SizedBox(height: 16.0),
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
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 19.0),
                      Row(
                        children: [
                          SizedBox(
                            width: 150, // Desired width
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
                            width: 210, // Desired width
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
                                "No harsh event detected",
                                style: GoogleFonts.inter(
                                  color: Colors.black,
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
      ),
    );
  }
}