import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:st/src/domain/entities/route.dart';
import 'package:st/src/domain/repositories/route_repository.dart';

class SavedRoutesController extends Controller {
  SavedRoutesController(
    RouteRepository routeRepository,
  ) : _routeRepository = routeRepository;

  RouteRepository _routeRepository;
  StreamSubscription? _savedRoutesStream;

  List<Route>? savedRoutes;

  @override
  void onDisposed() {
    if (_savedRoutesStream != null) _savedRoutesStream!.cancel();
    super.onDisposed();
  }

  @override
  void initListeners() {
    _savedRoutesStream = _routeRepository.getSavedRoutesStream().listen((routes) {
      if (routes != null) {
        savedRoutes = routes;
        refreshUI();
      }
    });
  }

  void removeSavedRoute(Route route) async {
    refreshUI();
    await _routeRepository.removeSavedRoute(route);
  }
}
