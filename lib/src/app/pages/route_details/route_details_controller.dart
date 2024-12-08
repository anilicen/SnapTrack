import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:st/src/app/navigator.dart';
import 'package:st/src/app/widgets/primary_popup.dart';
import 'package:st/src/data/helpers/geolocation_helper.dart';
import 'package:st/src/data/helpers/uuid_helper.dart';
import 'package:st/src/domain/entities/challenge.dart';
import 'package:st/src/domain/entities/route.dart' as st;
import 'package:st/src/domain/repositories/challenge_repository.dart';
import 'package:st/src/domain/repositories/route_repository.dart';

class RouteDetailsController extends Controller {
  RouteDetailsController(
    ChallengeRepository challengeRepository,
    RouteRepository routeRepository,
    st.Route route,
  )   : _challengeRepository = challengeRepository,
        _routeRepository = routeRepository,
        route = route;

  ChallengeRepository _challengeRepository;
  RouteRepository _routeRepository;

  st.Route route;
  List<st.Route>? savedRoutes;

  bool loading = false;
  bool areButtonsVisible = false;
  bool togglingSavedRoute = false;
  String difficulty = '';
  int thresholdValue = 0;

  MapController mapController = MapController();
  PanelController panelController = PanelController();

  StreamSubscription? _savedRoutesStream;

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

  void startChallenge() async {
    if (!await GeolocationHelper.isCloseEnough(route.firstCheckpoint.location)) {
      PrimaryPopup(
        title: 'SnapTrack',
        content:
            'You can’t start the challenge here. In order to start a route you should be at most 5 km away from the first checkpoint.',
        context: getContext(),
      ).showDefaultPopup();

      return;
    }

    if (loading) return;

    loading = true;
    refreshUI();

    Challenge? response = await _challengeRepository.getChallenge(route.id);

    if (response == null) {
      String challengeId = UuidHelper.getUniqueId();

      await _challengeRepository.startChallenge(challengeId, route.id);

      response = Challenge(
        id: challengeId,
        route: route,
        completedCheckpointIds: [],
        startedAt: DateTime.now(),
        finishedAt: null,
      );
    }

    STNavigator.navigateToChallengeView(getContext(), response, thresholdValue);
  }

  bool checkIsSavedRoute() {
    return savedRoutes!.any((savedRoute) => savedRoute.id == route.id);
  }

  void addSavedRoute() async {
    if (togglingSavedRoute) return;

    togglingSavedRoute = true;

    await _routeRepository.addSavedRoute(route);

    togglingSavedRoute = false;

    refreshUI();
  }

  void removeSavedRoute() async {
    if (togglingSavedRoute) return;

    togglingSavedRoute = true;

    await _routeRepository.removeSavedRoute(route);

    togglingSavedRoute = false;

    refreshUI();
  }

  void toggleButtonsVisibility() {
    areButtonsVisible = !areButtonsVisible;
    refreshUI();
  }

  void selectDifficulty(String difficulty) {
    if (difficulty == 'easy') {
      thresholdValue = 60;
    } else if (difficulty == 'medium') {
      thresholdValue = 70;
    } else if (difficulty == 'hard') {
      thresholdValue = 80;
    } else if (difficulty == 'extreme') {
      thresholdValue = 90;
    }
    startChallenge();
    refreshUI();
  }
}
