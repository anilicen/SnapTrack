import 'package:st/src/domain/entities/route.dart';

class Challenge {
  final String id;
  final Route route;
  final List<String> completedCheckpointIds;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  Challenge({
    required this.id,
    required this.route,
    required this.completedCheckpointIds,
    required this.startedAt,
    required this.finishedAt,
  });

  Challenge.fromJson(Map<String, dynamic> json, String docId, Route routeData)
      : id = docId,
        route = routeData,
        completedCheckpointIds = List<String>.from(json['completedCheckpointIds']),
        startedAt = DateTime.parse(json['startedAt']),
        finishedAt = json['finishedAt'] == null ? null : DateTime.parse(json['finishedAt']);
}
