// ignore_for_file: unused_field

import 'package:flutter/services.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:st/src/data/helpers/firestore_helper.dart';
import 'package:st/src/data/utils/string_utils.dart';
import 'package:st/src/domain/entities/route.dart';
import 'package:st/src/domain/repositories/route_repository.dart';

class EnterRouteDetailsController extends Controller {
  EnterRouteDetailsController(
    RouteRepository routeRepository,
  ) : _routeRepository = routeRepository;

  RouteRepository _routeRepository;

  Route? route;
  String? routeId;
  String? unpublishedRouteId;
  int selectedIndex = 0;
  String routeName = '';
  bool isPrivate = false;

  @override
  void initListeners() {}

  @override
  Future<void> onInitState() async {
    getRoute();
    super.onInitState();
  }

  Future<void> getRoute() async {
    route = await FirestoreHelper.getUnpublishedRoute();
    unpublishedRouteId = route!.id;
    route = route!.copyWith(coverPhotoUrl: route!.checkpoints[selectedIndex].photoUrl);

    refreshUI();
  }

  void selectIndex(int index) {
    selectedIndex = index;
    HapticFeedback.lightImpact();
    route = route!.copyWith(coverPhotoUrl: route!.checkpoints[selectedIndex].photoUrl);
    refreshUI();
  }

  void setRouteName(String name) {
    routeName = name;
    route = route!.copyWith(name: name);
    refreshUI();
  }

  void togglePrivate(bool value) {
    isPrivate = !isPrivate;
    HapticFeedback.lightImpact();
    route = route!.copyWith(isPrivate: isPrivate);
    refreshUI();
  }

  Future<void> addRoute() async {
    List<String> substrings = await StringUtils().generateSubstrings(route!.name);
    GeoFirePoint geoPoint = GeoFlutterFire().point(
      latitude: route!.checkpoints.first.location.latitude.toDouble(),
      longitude: route!.checkpoints.first.location.longitude.toDouble(),
    );

    route = route!.copyWith(
      substrings: substrings,
      location: geoPoint.data,
    );

    routeId = await _routeRepository.addRoute(route!);
  }

  bool isRouteNameInitialized() {
    return routeName.trim().isNotEmpty;
  }
}
