import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class GetLocation {
  const HomeScreen({super.key});

  double latitude = 0.0000;
  double longitude = 0.0000;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Latitude:- $latitude"
            ),
            Text(
                "Longitude:- $longitude"
            ),
          ],
        );
  }

  getUserCurrentLocation()async{
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        // Handle the case where the user did not enable the location service.
        normalConfirmationDialog(
            'Location Is Disable App wants to access your location',
            'Please, Enable your location',
            'Enable Location',
        );
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        // Handle the case where the user denied permission.
        normalConfirmationDialog(
            'Denied the location permission, Please go to settings and give access',
            'Location permission denied',
            'Open Settings'
        );
        print('Location_Permission_Denied:-');
        return;
      }
    }
    location.onLocationChanged.listen((LocationData currentLocation) async {
      // Handle location updates here.
      print("Location: ${currentLocation.latitude}, ${currentLocation.longitude}");
      setState(() {
        latitude = currentLocation.latitude!;
        longitude = currentLocation.longitude!;
      });

    });
  }

  normalConfirmationDialog(String confirmationText, String title, String buttonText) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image was here
              // const SizedBox(height: 20.0,), // SizedBox after image was here
              Text(title, style: TextStyle(fontSize: 20.0),),
              const SizedBox(height: 10.0,),
              Text(
                confirmationText,
              ),
              const SizedBox(height: 20.0,),
              ElevatedButton(
                  onPressed: (){
                    if(buttonText == 'Open Settings'){
                      AppSettings.openAppSettings();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(buttonText),
              )
            ],
          ),
        );
      },
    );
  }

}
