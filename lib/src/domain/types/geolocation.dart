import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class Geolocation {
  final num latitude;
  final num longitude;

  Geolocation({
    required this.latitude,
    required this.longitude,
  });

  Geolocation.fromJson(Map<String, dynamic> json)
      : latitude = json['latitude'],
        longitude = json['longitude'];

  Geolocation.fromPosition(Position position)
      : latitude = position.latitude,
        longitude = position.longitude;

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  LatLng toLatLng() {
    return LatLng(latitude.toDouble(), longitude.toDouble());
  }
}
