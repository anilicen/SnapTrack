import 'dart:async';
import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:st/src/domain/types/geolocation.dart';

class GeolocationHelper {
  static Future<Geolocation> getCurrentGeolocation() async {
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
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return Geolocation.fromPosition(await Geolocator.getCurrentPosition());
  }

  static StreamSubscription<Position> getLocationStream(Function(Position? position) onTriggered) {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings).listen(onTriggered);
  }

  static Future<bool> isCloseEnough(Geolocation checkpointLocation, {double? distance}) async {
    final currentLocation = await getCurrentGeolocation();

    return calculateDistance(currentLocation, checkpointLocation) < (distance ?? 5000);
  }

  static double calculateDistance(Geolocation location1, Geolocation location2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    // Convert latitude and longitude from degrees to radians
    double lat1 = _radians(location1.latitude.toDouble());
    double lon1 = _radians(location1.longitude.toDouble());
    double lat2 = _radians(location2.latitude.toDouble());
    double lon2 = _radians(location2.longitude.toDouble());

    // Haversine formula
    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    // Calculate distance
    double distance = earthRadius * c;

    // Convert to meters
    return distance * 1000;
  }

  static double _radians(double degrees) {
    return degrees * (pi / 180);
  }
}
