import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:st/src/domain/entities/route.dart';

class FirestoreHelper {
  static Future<Route?> getUnpublishedRoute() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snapshot = await FirebaseFirestore.instance.collection('unpublishedRoutes').doc(uid).get();

    final checkpoints =
        await FirebaseFirestore.instance.collection('unpublishedRoutes').doc(uid).collection('checkpoints').get();

    Route route = Route.fromJson(uid, snapshot, checkpoints);

    return route;
  }

  static Future<Route?> getRouteById(String routeId) async {
    final snapshot = await FirebaseFirestore.instance.collection('routes').doc(routeId).get();
    if (!snapshot.exists) {
      return null;
    }

    final checkpoints =
        await FirebaseFirestore.instance.collection('routes').doc(routeId).collection('checkpoints').get();

    Route route = Route.fromJson(routeId, snapshot, checkpoints);

    return route;
  }
}
