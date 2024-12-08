import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:st/src/domain/entities/route.dart';
import 'package:st/src/domain/repositories/route_repository.dart';
import 'package:st/src/domain/types/filter_by.dart';
import 'package:st/src/domain/types/route_data_state.dart';
import 'package:st/src/domain/types/sort_by.dart';

class RoutesController extends Controller {
  RoutesController(
    RouteRepository routeRepository,
  ) : _routeRepository = routeRepository;

  RouteRepository _routeRepository;

  StreamSubscription? _savedRoutesStream;

  PagingController<int, dynamic> pagingController = PagingController(firstPageKey: 0);

  bool isSearching = false;
  bool togglingSavedRoute = false;
  RouteDataState routeDataState = RouteDataState.raw;

  List<Route>? savedRoutes;
  List<Route> searchedRoutes = [];

  Route? lastRoute;

  SortBy? sortBy;
  FilterBy filterBy = FilterBy(duration: 0, length: 0, rating: 0, range: 0);

  int startFrom = 0;

  @override
  void onInitState() {
    pagingController.addPageRequestListener((pageKey) {
      if (routeDataState == RouteDataState.filtered) {
        filterAndSortRoutes();
      } else if (routeDataState == RouteDataState.searched) {
        // If pagination is implemented to searchRoute, Better Call searchRoute with last searchValue
      } else {
        getPublicRoutes();
      }
    });

    super.onInitState();
  }

  @override
  void onDisposed() {
    if (_savedRoutesStream != null) _savedRoutesStream!.cancel();
    super.onDisposed();
  }

  @override
  void initListeners() {
    _savedRoutesStream = _routeRepository.getSavedRoutesStream().listen(
      (routes) {
        if (routes != null) {
          savedRoutes = routes;
          refreshUI();
        }
      },
    );
  }

  void getPublicRoutes() async {
    try {
      if (routeDataState != RouteDataState.raw) {
        routeDataState = RouteDataState.raw;
        startFrom = 0;
        lastRoute = null;
        pagingController.refresh();
        return;
      }

      final routes = await _routeRepository.getPublicRoutes(
        itemsPerPage: 10,
        startFrom: lastRoute == null ? null : lastRoute!.snapshot,
      );

      if (routes.isEmpty) {
        pagingController.appendLastPage([]);
        return;
      }

      lastRoute = routes.last;
      startFrom += 10;

      if (routes.length < 10) {
        pagingController.appendLastPage(routes);
      } else {
        pagingController.appendPage(routes, startFrom);
      }
    } catch (e, st) {
      print(e);
      print(st);
      pagingController.error = e;
    }
  }

  Future<void> searchRoutes(String searchValue) async {
    try {
      if (searchValue.isEmpty) {
        routeDataState = RouteDataState.raw;
        startFrom = 0;
        lastRoute = null;
        pagingController.refresh();
        return;
      }

      routeDataState = RouteDataState.searched;
      startFrom = 0;
      lastRoute = null;
      pagingController.refresh();
      // If pagination is implemented to searchRoute, comment in the line below
      // return;

      final routes = await _routeRepository.searchRoutes(searchValue);

      // TODO: Can be improved by adding limit and startFrom parameters to searchRoutes
      pagingController.appendLastPage(routes);
    } catch (e, st) {
      print(e);
      print(st);
      pagingController.error = e;
    }
  }

  void filterAndSortRoutes({bool reset = false}) async {
    try {
      if (routeDataState != RouteDataState.filtered || reset) {
        routeDataState = RouteDataState.filtered;
        startFrom = 0;
        lastRoute = null;
        pagingController.refresh();
        return;
      }

      final routes = await _routeRepository.getPublicRoutes(
        itemsPerPage: 10,
        startFrom: lastRoute == null ? null : lastRoute!.snapshot,
        filterBy: filterBy,
        sortBy: sortBy,
      );

      if (routes.isEmpty) {
        pagingController.appendLastPage([]);
        return;
      }

      lastRoute = routes.last;
      startFrom += 10;

      if (routes.length < 10) {
        pagingController.appendLastPage(routes);
      } else {
        pagingController.appendPage(routes, startFrom);
      }
    } catch (e, st) {
      print(e);
      print(st);
      pagingController.error = e;
    }
  }

  void addSavedRoute(Route route) async {
    if (togglingSavedRoute) return;

    togglingSavedRoute = true;

    await _routeRepository.addSavedRoute(route);

    togglingSavedRoute = false;
  }

  void removeSavedRoute(Route route) async {
    if (togglingSavedRoute) return;

    togglingSavedRoute = true;

    await _routeRepository.removeSavedRoute(route);

    togglingSavedRoute = false;
  }

  bool isSavedRoute(Route route) {
    return savedRoutes!.any((savedRoute) => savedRoute.id == route.id);
  }

  void updateSortBy(SortBy value) {
    sortBy = value;

    refreshUI();
  }

  void refresh() {
    routeDataState = RouteDataState.raw;
    startFrom = 0;
    lastRoute = null;
    pagingController.refresh();
  }
}
