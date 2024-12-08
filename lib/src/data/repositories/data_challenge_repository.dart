import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:st/src/data/constants.dart';
import 'package:st/src/data/helpers/firestore_helper.dart';
import 'package:st/src/domain/entities/challenge.dart';
import 'package:st/src/domain/entities/route.dart';
import 'package:st/src/domain/repositories/challenge_repository.dart';
import 'package:http/http.dart' as http;

class DataChallengeRepository implements ChallengeRepository {
  static final _instance = DataChallengeRepository._internal();
  DataChallengeRepository._internal();
  factory DataChallengeRepository() => _instance;

  static final _firestore = FirebaseFirestore.instance;
  static final _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<Challenge?> getChallenge(String routeId) async {
    try {
      final response = await _firestore
          .collection('challenges')
          .where('routeId', isEqualTo: routeId)
          .where('userId', isEqualTo: _firebaseAuth.currentUser!.uid)
          .get();

      if (response.docs.isEmpty) return null;

      final route = await FirestoreHelper.getRouteById(routeId);

      return Challenge.fromJson(response.docs.first.data(), response.docs.first.id, route!);
    } catch (e, st) {
      print(e);
      print(st);
      rethrow;
    }
  }

  @override
  Future<void> startChallenge(String challengeId, String routeId) async {
    try {
      await _firestore.collection('challenges').doc(challengeId).set({
        'userId': _firebaseAuth.currentUser!.uid,
        'routeId': routeId,
        'startedAt': DateTime.now().toIso8601String(),
        'finishedAt': null,
        'completedCheckpointIds': [],
      });
    } catch (e, st) {
      print(e);
      print(st);
      rethrow;
    }
  }

  Future<List<Route>?> getJoinedChallenges() async {
    try {
      final challengeSnapshot =
          await _firestore.collection('challenges').where('userId', isEqualTo: _firebaseAuth.currentUser!.uid).get();

      if (challengeSnapshot.docs.isEmpty) return [];
      List<Route> routes = [];

      for (int index = 0; index < challengeSnapshot.docs.length; index++) {
        final routeId = challengeSnapshot.docs.elementAt(index).data()['routeId'];

        if (routeId != null) {
          final route = await FirestoreHelper.getRouteById(routeId);
          if (route != null) routes.add(route);
        }
      }

      routes.sort((b, a) => a.createdAt.compareTo(b.createdAt));

      return routes;
    } catch (e, st) {
      print(e);
      print(st);
      rethrow;
    }
  }

  @override
  Future<void> removeChallenge(String routeId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('challenges')
          .where('routeId', isEqualTo: routeId)
          .where('userId', isEqualTo: _firebaseAuth.currentUser!.uid)
          .get();

      final id = querySnapshot.docs[0].id;

      await _firestore.collection('challenges').doc(id).delete();
    } catch (e, st) {
      print(e);
      print(st);
      rethrow;
    }
  }

  @override
  Future<void> completeCheckpoint(String challengeId, String checkpointId) async {
    try {
      await _firestore.collection('challenges').doc(challengeId).update({
        'completedCheckpointIds': FieldValue.arrayUnion([checkpointId]),
      });
    } catch (e, st) {
      print(e);
      print(st);
      rethrow;
    }
  }

  @override
  Future<int> getImageSimilarityPercentage(String takenImagePath, String checkpointImageUrl) async {
    try {
      final checkpointImage = await http.get(Uri.parse(checkpointImageUrl));

      final uri = Uri.parse('$backendUrl');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(await http.MultipartFile.fromPath('image1', takenImagePath));
      request.files.add(http.MultipartFile.fromBytes('image2', checkpointImage.bodyBytes, filename: 'image2.jpg'));

      final streamedResponse = await request.send();

      final data = await streamedResponse.stream.bytesToString();

      return (double.parse(data) * 100).toInt();
    } catch (e, st) {
      print(e);
      print(st);
      rethrow;
    }
  }
}
