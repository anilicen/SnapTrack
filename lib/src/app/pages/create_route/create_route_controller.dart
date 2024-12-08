import 'dart:async';

import 'package:flutter/material.dart' hide Route;
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:st/src/data/helpers/geolocation_helper.dart';
import 'package:st/src/domain/entities/route.dart';
import 'package:st/src/domain/repositories/route_repository.dart';
import 'package:st/src/domain/types/geolocation.dart';

class CreateRouteController extends Controller {
  CreateRouteController(RouteRepository routeRepository) : _routeRepository = routeRepository;

  RouteRepository _routeRepository;

  MapController mapController = MapController();
  PanelController panelController = PanelController();

  Geolocation? currentGeolocation;
  Geolocation? lastLocation;

  StreamSubscription? _locationStream;
  StreamSubscription? _unpublishedRouteStream;

  Route? unpublishedRoute;

  @override
  void onInitState() {
    GeolocationHelper.getCurrentGeolocation().then((value) {
      currentGeolocation = value;
    });

    Future.delayed(Duration(milliseconds: 800)).then((_) {
      panelController.animatePanelToSnapPoint(
        duration: Duration(milliseconds: 900),
        curve: Curves.fastLinearToSlowEaseIn,
      );
    });

    super.onInitState();
  }

  @override
  void onDisposed() {
    if (_locationStream != null) _locationStream!.cancel();
    if (_unpublishedRouteStream != null) _unpublishedRouteStream!.cancel();
    mapController.dispose();
    super.onDisposed();
  }

  @override
  void initListeners() {
    _locationStream = GeolocationHelper.getLocationStream((position) {
      if (position == null || unpublishedRoute == null) return;

      if (unpublishedRoute!.path.isEmpty) {
        unpublishedRoute!.path.add(Geolocation.fromPosition(position));
        return;
      }

      bool isClose = false;

      for (int index = 0; index < unpublishedRoute!.path.length; index++) {
        if (GeolocationHelper.calculateDistance(unpublishedRoute!.path[index], Geolocation.fromPosition(position)) <
            5) {
          isClose = true;
          break;
        }
      }

      if (isClose) return;

      addPoint(Geolocation.fromPosition(position));
    });

    _unpublishedRouteStream = _routeRepository.getUnpublishedRouteStream().listen((route) {
      if (route != null) {
        unpublishedRoute = route.copyWith();
        refreshUI();
      }
    });
  }

  void addPoint(Geolocation geolocation) {
    _routeRepository.addPointToUnpublishedPath(geolocation);
  }

  Future<void> deleteCheckpoint(int order) async {
    await _routeRepository.deleteCheckpoint("", order);
    refreshUI();
  }
}
