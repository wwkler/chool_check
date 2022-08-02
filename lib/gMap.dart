
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Google Map을 보여주는 Under Widget
class CustomGoogleMap extends StatelessWidget {
  // Call By Reference로 운영
  final CameraPosition initalPosition;
  final Circle circle;
  final Marker marker;
  final Completer<GoogleMapController> completer;

  const CustomGoogleMap({
    Key? key,
    required this.initalPosition,
    required this.circle,
    required this.marker,
    required this.completer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: initalPosition,
        myLocationEnabled: true,
        circles: Set.from([circle]),
        markers: Set.from([marker]),
        onMapCreated: (GoogleMapController controller) async {
          completer.complete(controller);
        },
      ),
    );
  }
}