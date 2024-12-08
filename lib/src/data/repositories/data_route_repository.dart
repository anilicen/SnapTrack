import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:st/src/data/helpers/geolocation_helper.dart';
import 'package:st/src/data/helpers/upload_helper.dart';
import 'package:st/src/domain/entities/checkpoint.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:st/src/data/repositories/data_user_repository.dart';
import 'package:st/src/domain/entities/route.dart';
import 'package:st/src/domain/repositories/route_repository.dart';
import 'package:st/src/domain/types/filter_by.dart';
import 'package:st/src/domain/types/geolocation.dart';
import 'package:st/src/domain/types/sort_by.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

class DataRouteRepository implements RouteRepository {
  static final _instance = DataRouteRepository._internal();
  DataRouteRepository._internal();
  factory DataRouteRepository() => _instance;

  static final _firestore = FirebaseFirestore.instance;
  static final _firebaseAuth = FirebaseAuth.instance;

  final StreamController<Route?> _unpublishedRouteStream = StreamController.broadcast();
  final StreamController<List<Route>?> _savedRoutesStream = StreamController.broadcast();

  Route? _unpublishedRoute;
  List<Route>? _savedRoutes;
  bool _unpublishedRouteFetched = false;
  bool _savedRoutesFetched = false;

  @override
  Future<List<Route>> getPublicRoutes({
    required int itemsPerPage,
    DocumentSnapshot? startFrom,
    SortBy? sortBy = SortBy.newlyAdded,
    FilterBy? filterBy,
  }) async {
    try {
      var routesSnapshot;

      Query collectionQuery = _firestore.collection('routes');

      if (filterBy != null) {
        int lengthAsMeters = (filterBy.length! * 1000).toInt();
        int durationInMilliseconds = (filterBy.duration! * Duration.millisecondsPerHour).toInt();
        List<String> routeIds;

        if (filterBy.range != 0.0) {
          GeoFlutterFire geoFlutterFire = GeoFlutterFire();
          Geolocation userLocation = await GeolocationHelper.getCurrentGeolocation();

          GeoFirePoint searchCenter = geoFlutterFire.point(
            latitude: userLocation.latitude.toDouble(),
            longitude: userLocation.longitude.toDouble(),
          );

          print(filterBy.range);
          var snapshots = await geoFlutterFire
              .collection(collectionRef: _firestore.collection('routes'))
              .within(
                center: searchCenter,
                radius: filterBy.range! < 20.0 ? filterBy.range! : 6371,
                field: 'location',
                strictMode: true,
              )
              .first;

          routeIds = snapshots.map((snapshot) => snapshot.id).toList();

          if (routeIds.isNotEmpty) {
            collectionQuery = collectionQuery.where('id', whereIn: routeIds);
          }
        }

        collectionQuery = collectionQuery.where(
          Filter.and(
            Filter('rating', isGreaterThanOrEqualTo: filterBy.rating),
            Filter('duration', isGreaterThanOrEqualTo: durationInMilliseconds),
            Filter('length', isGreaterThanOrEqualTo: lengthAsMeters),
          ),
        );
      }

      if (sortBy == SortBy.highestRating) {
        collectionQuery = collectionQuery.orderBy('rating', descending: true);
      } else if (sortBy == SortBy.newlyAdded) {
        collectionQuery = collectionQuery.orderBy('createdAt', descending: true);
      } else if (sortBy == SortBy.highestParticipation) {
        collectionQuery = collectionQuery.orderBy('participantCount', descending: true);
      }

      if (startFrom == null)
        routesSnapshot = await collectionQuery.limit(itemsPerPage).get();
      else
        routesSnapshot = await collectionQuery.limit(itemsPerPage).startAfterDocument(startFrom).get();

      if (routesSnapshot.docs.isEmpty) return [];

      List<Route> routes = [];
      for (final doc in routesSnapshot.docs) {
        final checkpointsSnapshot = await _firestore.collection('routes').doc(doc.id).collection('checkpoints').get();
        final route = Route.fromJson(
          doc.id,
          doc,
          checkpointsSnapshot,
        );
        routes.add(route);
      }

      return routes;
    } catch (e, st) {
      print(e);
      print(st);
      rethrow;
    }
  }

  Future<List<Route>?> getMyRoutes() async {
    try {
      final routesSnapshot =
          await _firestore.collection('users').doc(_firebaseAuth.currentUser!.uid).collection('myRoutes').get();

      if (routesSnapshot.docs.isEmpty) return [];
      List<Route> routes = [];

      for (int index = 0; index < routesSnapshot.docs.length; index++) {
        final checkpointsSnapshot = await _firestore
            .collection('users')
            .doc(_firebaseAuth.currentUser!.uid)
            .collection('myRoutes')
            .doc(routesSnapshot.docs[index].id)
            .collection('checkpoints')
            .get();

        routes.add(Route.fromJson(routesSnapshot.docs[index].id, routesSnapshot.docs[index], checkpointsSnapshot));
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
  Future<void> addMyRoute(Route route) async {
    try {
      await _firestore
          .collection("users")
          .doc(_firebaseAuth.currentUser!.uid)
          .collection("myRoutes")
          .doc(route.id)
          .set(route.toJson());

      for (int index = 0; index < route.checkpointsCount; index++) {
        await _firestore
            .collection("users")
            .doc(_firebaseAuth.currentUser!.uid)
            .collection("myRoutes")
            .doc(route.id)
            .collection('checkpoints')
            .doc(route.checkpoints[index].id)
            .set(route.checkpoints[index].toJson());
      }
    } catch (e, st) {
      print(e);
      print(st);
      rethrow;
    }
  }

  @override
  Future<void> addSavedRoute(Route route) async {
    try {
      await _firestore
          .collection("users")
          .doc(_firebaseAuth.currentUser!.uid)
          .collection("savedRoutes")
          .doc(route.id)
          .set(route.toJson());

      for (int index = 0; index < route.checkpointsCount; index++) {
        await _firestore
            .collection("users")
            .doc(_firebaseAuth.currentUser!.uid)
            .collection("savedRoutes")
            .doc(route.id)
            .collection('checkpoints')
            .doc(route.checkpoints[index].id)
            .set(route.checkpoints[index].toJson());
      }
      _savedRoutes!.add(route);
      _savedRoutes!.sort((b, a) => a.createdAt.compareTo(b.createdAt));
      _savedRoutesStream.add(_savedRoutes!.toList());
    } catch (e, st) {
      print(e);
      print(st);
      rethrow;
    }
  }

  @override
  Future<void> removeSavedRoute(Route route) async {
    try {
      for (int index = 0; index < route.checkpointsCount; index++) {
        await _firestore
            .collection("users")
            .doc(_firebaseAuth.currentUser!.uid)
            .collection("savedRoutes")
            .doc(route.id)
            .collection("checkpoints")
            .doc(route.checkpoints.elementAt(index).id)
            .delete();
      }

      await _firestore
          .collection("users")
          .doc(_firebaseAuth.currentUser!.uid)
          .collection("savedRoutes")
          .doc(route.id)
          .delete();

      for (int index = 0; index < _savedRoutes!.length; index++) {
        if (route.id == _savedRoutes![index].id) {
          _savedRoutes!.removeAt(index);
        }
      }
      _savedRoutesStream.add(_savedRoutes!.toList());
    } catch (e, st) {
      print(e);
      print(st);
      rethrow;
    }
  }

  @override
  Future<void> addCheckpoint(String routeId, Checkpoint checkpoint) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      int minutes = 0;

      if (_unpublishedRoute!.checkpoints.isNotEmpty) {
        final distance =
            GeolocationHelper.calculateDistance(_unpublishedRoute!.checkpoints.last.location, checkpoint.location);

        minutes = distance ~/ 85;
      }

      await _firestore.collection('unpublishedRoutes').doc(uid).collection('checkpoints').add(checkpoint.toJson());
      await _firestore.collection('unpublishedRoutes').doc(uid).update({
        'updatedAt': DateTime.now().toIso8601String(),
        'duration': _unpublishedRoute!.duration.inMilliseconds + minutes * 60000,
      });
    } catch (e, st) {
      print(e);
      print(st);
      rethrow;
    }
  }

  Future<void> deleteCheckpoint(String checkpointId, int order) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      int minutes = 0;
      int checkpointListLength = _unpublishedRoute!.checkpoints.length;
      double distance = 0;

      if (checkpointListLength > 1) {
        if (order != 0)
          distance -= GeolocationHelper.calculateDistance(_unpublishedRoute!.checkpoints.elementAt(order - 1).location,
              _unpublishedRoute!.checkpoints.elementAt(order).location);
        if (order != checkpointListLength - 1)
          distance -= GeolocationHelper.calculateDistance(_unpublishedRoute!.checkpoints.elementAt(order).location,
              _unpublishedRoute!.checkpoints.elementAt(order + 1).location);
        if (order != checkpointListLength - 1 && order != 0)
          distance += GeolocationHelper.calculateDistance(_unpublishedRoute!.checkpoints.elementAt(order - 1).location,
              _unpublishedRoute!.checkpoints.elementAt(order + 1).location);
        if (order != checkpointListLength - 1) {
          for (int i = order + 1; i < checkpointListLength; i++) {
            Checkpoint checkpoint = _unpublishedRoute!.checkpoints.elementAt(i);

            _unpublishedRoute!.checkpoints[i] = checkpoint.copyWith(order: i - 1);

            QuerySnapshot querySnapshot = await _firestore
                .collection('unpublishedRoutes')
                .doc(uid)
                .collection('checkpoints')
                .where("order", isEqualTo: i)
                .get();

            final id = querySnapshot.docs[0].id;

            await _firestore.collection('unpublishedRoutes').doc(uid).collection('checkpoints').doc(id).update({
              'order': i - 1,
            });
          }
        }
      }

      minutes = distance ~/ 85;

      QuerySnapshot querySnapshot = await _firestore
          .collection('unpublishedRoutes')
          .doc(uid)
          .collection('checkpoints')
          .where("order", isEqualTo: order)
          .get();

      final id = querySnapshot.docs[0].id;

      await _firestore.collection('unpublishedRoutes').doc(uid).collection('checkpoints').doc(id).delete();

      await _firestore.collection('unpublishedRoutes').doc(uid).update({
        'updatedAt': DateTime.now().toIso8601String(),
        'duration': _unpublishedRoute!.duration.inMilliseconds + minutes * 60000,
      });
    } catch (e, st) {
      print(e);
      print(st);
      rethrow;
    }
  }

  void _initSavedRoutesStream() async {
    try {
      final savedRoutesSnapshot =
          await _firestore.collection("users").doc(_firebaseAuth.currentUser!.uid).collection("savedRoutes").get();

      List<Route> savedRoutes = [];

      for (int index = 0; index < savedRoutesSnapshot.docs.length; index++) {
        final checkpointsSnapshot = await _firestore
            .collection("users")
            .doc(_firebaseAuth.currentUser!.uid)
            .collection("savedRoutes")
            .doc(savedRoutesSnapshot.docs[index].id)
            .collection('checkpoints')
            .get();

        savedRoutes.add(
            Route.fromJson(savedRoutesSnapshot.docs[index].id, savedRoutesSnapshot.docs[index], checkpointsSnapshot));
      }

      savedRoutes.sort((b, a) => a.createdAt.compareTo(b.createdAt));

      _savedRoutes = savedRoutes;
      _savedRoutesFetched = true;
      _savedRoutesStream.add(_savedRoutes!.toList());
    } catch (e, st) {
      print(e);
      print(st);
      rethrow;
    }
  }

  Stream<List<Route>?> getSavedRoutesStream() {
    try {
      if (!_savedRoutesFetched) _initSavedRoutesStream();

      Future.delayed(Duration.zero)
          .then((_) => _savedRoutesStream.add(_savedRoutes == null ? null : _savedRoutes!.toList()));

      return _savedRoutesStream.stream;
    } catch (e, st) {
      print(e);
      print(st);
      rethrow;
    }
  }

  void _initUnpublishedRouteStream() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final snapshot = await _firestore.collection('unpublishedRoutes').doc(uid).get();

      if (snapshot.data() == null) {
        final currentUser = await DataUserRepository().getUser();
        final newRoute = Route(
          id: '',
          name: '',
          coverPhotoUrl: '',
          checkpoints: [],
          path: [],
          duration: Duration.zero,
          isPrivate: false,
          shareLink: '',
          createdBy: currentUser,
          createdAt: DateTime.now(),
          participantCount: 0,
          rating: 0,
          length: 0,
          location: GeoFlutterFire()
              .point(
                latitude: 0,
                longitude: 0,
              )
              .data,
          substrings: <String>[],
        );

        await _firestore.collection('unpublishedRoutes').doc(uid).set(newRoute.toJson());
      }

      _unpublishedRouteFetched = true;

      // A user can only have one unpublished route, that is why it is okay to use user id here
      _firestore.collection('unpublishedRoutes').doc(uid).snapshots().listen((snapshot) async {
        final checkpointsData =
            await _firestore.collection('unpublishedRoutes').doc(uid).collection('checkpoints').get();
        // No route id yet since it is not published
        if (snapshot.data() == null) return;

        final route = Route.fromJson('', snapshot, checkpointsData);
        _unpublishedRoute = route;
        _unpublishedRouteStream.add(_unpublishedRoute);
      });
    } catch (e, st) {
      print(e);
      print(st);
    }
  }

  @override
  Stream<Route?> getUnpublishedRouteStream() {
    try {
      if (!_unpublishedRouteFetched) _initUnpublishedRouteStream();

      Future.delayed(Duration.zero).then((_) => _unpublishedRouteStream.add(_unpublishedRoute));

      return _unpublishedRouteStream.stream;
    } catch (e, st) {
      print(e);
      print(st);
      rethrow;
    }
  }

  @override
  Future<String?> uploadCheckpointPhoto(String routeId, String imagePath) async {
    try {
      String? downloadURL = await UploadHelper.uploadPhoto(routeId, 'checkpoint-images', imagePath);

      return downloadURL;
    } catch (e, st) {
      print('Error uploading image: $e');
      print(st);
      rethrow;
    }
  }

  @override
  Future<void> addPointToUnpublishedPath(Geolocation geolocation) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await _firestore.collection('unpublishedRoutes').doc(uid).update({
        'path': FieldValue.arrayUnion([geolocation.toJson()]),
      });

      _unpublishedRoute!.path.add(geolocation);
      _unpublishedRouteStream.add(_unpublishedRoute);
    } catch (e, st) {
      print(e);
      print(st);
      rethrow;
    }
  }

  @override
  Future<String> addRoute(Route route) async {
    try {
      GeoFirePoint locationData = GeoFlutterFire().point(
        latitude: route.checkpoints.first.location.latitude.toDouble(),
        longitude: route.checkpoints.first.location.longitude.toDouble(),
      );

      final newId = _firestore.collection('routes').doc().id;
      Route newRoute = route.copyWith(id: newId, location: locationData.data);

      await _firestore.collection('routes').doc(newId).set(newRoute.toJson());

      for (int index = 0; index < route.checkpointsCount; index++) {
        await _firestore
            .collection('routes')
            .doc(newId)
            .collection('checkpoints')
            .doc(route.checkpoints[index].id)
            .set(route.checkpoints[index].toJson());
      }

      addMyRoute(newRoute);

      deleteUnpublishedRoute(route);

      return newId;
    } catch (e, st) {
      print(e);
      print(st);
      rethrow;
    }
  }

  Future<void> deleteRoute(Route route) async {
    try {
      // Delete from Joined Challenges

      // Delete from Public Routes
      for (int index = 0; index < route.checkpointsCount; index++) {
        await _firestore
            .collection('routes')
            .doc(route.id)
            .collection("checkpoints")
            .doc(route.checkpoints.elementAt(index).id)
            .delete();
      }
      await _firestore.collection('routes').doc(route.id).delete();

      // Delete from My Routes
      for (int index = 0; index < route.checkpointsCount; index++) {
        await _firestore
            .collection("users")
            .doc(_firebaseAuth.currentUser!.uid)
            .collection("myRoutes")
            .doc(route.id)
            .collection("checkpoints")
            .doc(route.checkpoints.elementAt(index).id)
            .delete();
      }
      await _firestore
          .collection("users")
          .doc(_firebaseAuth.currentUser!.uid)
          .collection("myRoutes")
          .doc(route.id)
          .delete();

      // Delete from Saved Routes
      // Get all users
      QuerySnapshot userSnapshot = await _firestore.collection("users").get();

      // Iterate over each user
      for (DocumentSnapshot userDoc in userSnapshot.docs) {
        String userId = userDoc.id;

        // Delete the document from the user's collection of saved routes
        for (int index = 0; index < route.checkpointsCount; index++) {
          await _firestore
              .collection("users")
              .doc(userId)
              .collection("savedRoutes")
              .doc(route.id)
              .collection("checkpoints")
              .doc(route.checkpoints.elementAt(index).id)
              .delete();
        }

        await _firestore.collection("users").doc(userId).collection("savedRoutes").doc(route.id).delete();
      }
    } catch (e, st) {
      print(e);
      print(st);
      rethrow;
    }
  }

  Future<void> deleteUnpublishedRoute(Route unpublishedRoute) async {
    try {
      for (int index = 0; index < unpublishedRoute.checkpointsCount; index++) {
        await _firestore
            .collection('unpublishedRoutes')
            .doc(unpublishedRoute.id)
            .collection("checkpoints")
            .doc(unpublishedRoute.checkpoints.elementAt(index).id)
            .delete();
      }
      await _firestore.collection('unpublishedRoutes').doc(unpublishedRoute.id).delete();

      _unpublishedRoute = null;
      _unpublishedRouteFetched = false;
    } catch (e, st) {
      print(e);
      print(st);
      rethrow;
    }
  }

  Future<List<Route>> searchRoutes(String input) async {
    String lowercasedInput = input.toLowerCase();
    final searchedRoutesSnapshot = await _firestore
        .collection('routes')
        .where("substrings", arrayContains: lowercasedInput)
        .orderBy('createdAt', descending: true)
        .get();

    List<Route> searchedRoutes = [];

    for (int index = 0; index < searchedRoutesSnapshot.docs.length; index++) {
      final checkpointsSnapshot = await _firestore
          .collection("routes")
          .doc(searchedRoutesSnapshot.docs[index].id)
          .collection('checkpoints')
          .get();

      searchedRoutes.add(
        Route.fromJson(
          searchedRoutesSnapshot.docs[index].id,
          searchedRoutesSnapshot.docs[index],
          checkpointsSnapshot,
        ),
      );
    }
    return searchedRoutes;
  }
}
