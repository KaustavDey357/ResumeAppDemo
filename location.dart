import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:app_settings/app_settings.dart';

class GetLocation extends StatefulWidget {
  const GetLocation({super.key});

  @override
  State<GetLocation> createState() => _GetLocationState();
}

class _GetLocationState extends State<GetLocation> {
  double latitude = 0.0;
  double longitude = 0.0;
  final Location location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    getUserCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          "Lat: ${latitude.toStringAsFixed(4)}, Lng: ${longitude.toStringAsFixed(4)}",
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
      ],
    );
  }

  Future<void> getUserCurrentLocation() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        showConfirmationDialog(
          'Location is disabled. App wants to access your location.',
          'Please enable your location.',
          'Enable Location',
        );
        return;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        showConfirmationDialog(
          'Denied the location permission. Please go to settings and give access.',
          'Location permission denied',
          'Open Settings',
        );
        return;
      }
    }

    _locationSubscription = location.onLocationChanged.listen((currentLocation) {
      setState(() {
        latitude = currentLocation.latitude ?? 0.0;
        longitude = currentLocation.longitude ?? 0.0;
      });
    });
  }

  void showConfirmationDialog(String confirmationText, String title, String buttonText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(confirmationText),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (buttonText == 'Open Settings') {
                AppSettings.openAppSettings();
              } else {
                Navigator.pop(context);
                getUserCurrentLocation(); // retry after enabling
              }
            },
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}
