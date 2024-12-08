import 'package:st/src/domain/types/geolocation.dart';

class Checkpoint {
  final String id;
  final String name;
  final Geolocation location;
  final String photoUrl;
  final int order;

  Checkpoint(this.id, this.name, this.location, this.photoUrl, this.order);

  Checkpoint.fromJson(String id, Map<String, dynamic> json)
      : id = id,
        name = json['name'],
        location = Geolocation.fromJson(json['location']),
        photoUrl = json['photoUrl'],
        order = json['order'];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location.toJson(),
      'photoUrl': photoUrl,
      'order': order,
    };
  }

  Checkpoint copyWith({
    String? id,
    String? name,
    Geolocation? location,
    String? photoUrl,
    int? order,
  }) {
    return Checkpoint(
      id ?? this.id,
      name ?? this.name,
      location ?? this.location,
      photoUrl ?? this.photoUrl,
      order ?? this.order,
    );
  }
}
