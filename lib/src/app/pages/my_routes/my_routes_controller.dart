import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:st/src/domain/entities/route.dart';
import 'package:st/src/domain/repositories/route_repository.dart';

class MyRoutesController extends Controller {
  MyRoutesController(
    RouteRepository routeRepository,
  ) : _routeRepository = routeRepository;

  final RouteRepository _routeRepository;

  List<Route>? myRoutes;

  @override
  void onInitState() {
    getMyRoutes();
    super.onInitState();
  }

  @override
  void initListeners() {}

  void getMyRoutes() async {
    myRoutes = await _routeRepository.getMyRoutes();
    refreshUI();
  }

  void removeMyRoute(Route route) async {
    await _routeRepository.deleteRoute(route);
    myRoutes!.remove(route);
    refreshUI();
  }
}
