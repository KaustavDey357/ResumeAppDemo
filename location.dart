import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:app_settings/app_settings.dart';

class GetLocation extends StatefulWidget {
  const GetLocation({super.key});

  @override
  State<GetLocation> createState() => _GetLocationState();
}

class _GetLocationState extends State<GetLocation> with WidgetsBindingObserver {
  double latitude = 0.0;
  double longitude = 0.0;
  final Location location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  bool _checking = false; // Prevent multiple parallel checks

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserCurrentLocation();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getUserCurrentLocation(); // recheck when returning from settings
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasLocation = latitude != 0.0 || longitude != 0.0;
    final text = hasLocation
        ? "Lat: ${latitude.toStringAsFixed(4)}, Lng: ${longitude.toStringAsFixed(4)}"
        : "Locating…";

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Future<void> getUserCurrentLocation() async {
    if (_checking) return;
    _checking = true;

    try {
      // 1. Check service
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          await _showDialog(
            title: 'Location Service Disabled',
            message: 'Location is turned off. Please enable it to continue.',
            actionLabel: 'Enable Location',
            openSettings: false,
          );
          return;
        }
      }

      // 2. Check permissions
      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
      }

      if (permissionGranted == PermissionStatus.deniedForever) {
        await _showDialog(
          title: 'Permission Denied Forever',
          message:
              'Location permission permanently denied. Please open app settings to grant access.',
          actionLabel: 'Open Settings',
          openSettings: true,
        );
        return;
      }

      if (permissionGranted != PermissionStatus.granted) {
        await _showDialog(
          title: 'Location Permission Denied',
          message:
              'Location permission denied. Please open app settings to allow access.',
          actionLabel: 'Open Settings',
          openSettings: true,
        );
        return;
      }

      // 3. Configure accuracy
      location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 2000,
        distanceFilter: 5,
      );

      // 4. Subscribe to location
      _locationSubscription?.cancel();
      _locationSubscription =
          location.onLocationChanged.listen((LocationData currentLocation) {
        if (!mounted) return;
        setState(() {
          latitude = currentLocation.latitude ?? 0.0;
          longitude = currentLocation.longitude ?? 0.0;
        });
      });
    } catch (e) {
      debugPrint('Location error: $e');
    } finally {
      _checking = false;
    }
  }

  Future<void> _showDialog({
    required String title,
    required String message,
    required String actionLabel,
    required bool openSettings,
  }) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (openSettings && Platform.isAndroid) {
                // Only for Android
                AppSettings.openAppSettings();
              } else if (!openSettings) {
                // Retry after enabling location or closing dialog
                Future.delayed(const Duration(seconds: 1), () {
                  getUserCurrentLocation();
                });
              }
            },
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
