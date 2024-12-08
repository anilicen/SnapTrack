import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:st/src/domain/entities/checkpoint.dart';
import 'package:st/src/domain/entities/route.dart';
import 'package:st/src/domain/types/filter_by.dart';
import 'package:st/src/domain/types/geolocation.dart';
import 'package:st/src/domain/types/sort_by.dart';

abstract class RouteRepository {
  Future<List<Route>> getPublicRoutes({
    required int itemsPerPage,
    DocumentSnapshot? startFrom,
    SortBy? sortBy = SortBy.newlyAdded,
    FilterBy? filterBy,
  });
  Future<List<Route>?> getMyRoutes();
  Future<String> addRoute(Route route);
  Future<void> addMyRoute(Route route);
  Future<void> addSavedRoute(Route route);
  Future<void> removeSavedRoute(Route route);
  Future<void> addCheckpoint(String routeId, Checkpoint checkpoint);
  Future<void> deleteCheckpoint(String checkpointId, int order);
  Future<String?> uploadCheckpointPhoto(String routeId, String imagePath);
  Stream<List<Route>?> getSavedRoutesStream();
  Stream<Route?> getUnpublishedRouteStream();
  Future<void> addPointToUnpublishedPath(Geolocation geolocation);
  Future<void> deleteRoute(Route route);
  Future<void> deleteUnpublishedRoute(Route unpublishedRoute);
  Future<List<Route>> searchRoutes(String input);
}
