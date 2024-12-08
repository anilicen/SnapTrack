import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:st/src/domain/entities/checkpoint.dart';
import 'package:st/src/domain/entities/user.dart';
import 'package:st/src/domain/types/geolocation.dart';

class Route {
  final String id;
  final String name;
  final String coverPhotoUrl;
  final List<Checkpoint>
      checkpoints; // Needs to be stored at a nested collection in a route document. fromJson function should be written carefully
  final List<Geolocation> path;
  final Duration duration;
  final bool isPrivate;
  final String shareLink;
  final User createdBy;
  final DateTime createdAt;
  final int participantCount;
  final double rating;
  final double length;
  final Map<String, dynamic> location;
  final List<String> substrings;
  final DocumentSnapshot? snapshot;

  Route({
    required this.id,
    required this.name,
    required this.coverPhotoUrl,
    required this.checkpoints,
    required this.path,
    required this.duration,
    required this.isPrivate,
    required this.shareLink,
    required this.createdBy,
    required this.createdAt,
    required this.participantCount,
    required this.rating,
    required this.length,
    required this.location,
    required this.substrings,
    this.snapshot,
  });

  int get checkpointsCount => checkpoints.length;

  Checkpoint get firstCheckpoint => checkpoints.firstWhere((e) => e.order == 0);

  Route copyWith({
    String? id,
    String? name,
    String? coverPhotoUrl,
    List<Checkpoint>? checkpoints,
    List<Geolocation>? path,
    Duration? duration,
    bool? isPrivate,
    String? shareLink,
    User? createdBy,
    DateTime? createdAt,
    int? participantCount,
    double? rating,
    double? length,
    Map<String, dynamic>? location,
    List<String>? substrings,
    DocumentSnapshot? snapshot,
  }) {
    return Route(
      id: id ?? this.id,
      name: name ?? this.name,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      checkpoints: checkpoints ?? this.checkpoints,
      path: path ?? this.path,
      duration: duration ?? this.duration,
      isPrivate: isPrivate ?? this.isPrivate,
      shareLink: shareLink ?? this.shareLink,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      participantCount: participantCount ?? this.participantCount,
      rating: rating ?? this.rating,
      length: length ?? this.length,
      location: location ?? this.location,
      substrings: substrings ?? this.substrings,
      snapshot: snapshot ?? this.snapshot,
    );
  }

  @override
  String toString() {
    return 'id: $id, name: $name, coverPhotoUrl: $coverPhotoUrl, checkPointsCount: ${checkpoints.length} ,routeDuration: $duration, publishDate: $createdAt, rating:$rating \n';
  }

  Route.fromJson(
      String id, DocumentSnapshot<Map<String, dynamic>> snapshot, QuerySnapshot<Map<String, dynamic>> checkpointsData)
      : id = id,
        name = snapshot.data()!['name'],
        coverPhotoUrl = snapshot.data()!['coverPhotoUrl'],
        checkpoints = List<Checkpoint>.from(
            checkpointsData.docs.map((checkpointData) => Checkpoint.fromJson(checkpointData.id, checkpointData.data())))
          ..sort(
            (a, b) => a.order.compareTo(b.order),
          ),
        path =
            List<Geolocation>.from(snapshot.data()!['path'].map((locationData) => Geolocation.fromJson(locationData))),
        duration = Duration(milliseconds: snapshot.data()!['duration']),
        isPrivate = snapshot.data()!['isPrivate'],
        shareLink = snapshot.data()!['shareLink'],
        createdBy = User.fromJson(snapshot.data()!['createdBy'], "0"),
        createdAt = DateTime.parse(snapshot.data()!['createdAt']),
        participantCount = snapshot.data()!['participantCount'],
        rating = snapshot.data()!['rating'].toDouble(),
        length = snapshot.data()!['length'].toDouble(),
        location = snapshot.data()!['location'],
        substrings = snapshot.data()!['substrings'] == null ? [] : List<String>.from(snapshot.data()!['substrings']),
        snapshot = snapshot;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coverPhotoUrl': coverPhotoUrl,
      'path': path.map((location) => location.toJson()).toList(),
      'duration': duration.inMilliseconds,
      'isPrivate': isPrivate,
      'shareLink': shareLink,
      'createdBy': createdBy.toJson(),
      'createdAt': createdAt.toIso8601String(),
      // We don't need it on app right now but we will use it to triger route listener
      'updatedAt': DateTime.now().toIso8601String(),
      'participantCount': participantCount,
      'rating': rating,
      'length': length,
      'location': location,
      'substrings': substrings,
    };
  }
}
