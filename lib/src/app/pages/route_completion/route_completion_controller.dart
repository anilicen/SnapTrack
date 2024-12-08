// ignore_for_file: unused_field

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:st/src/data/helpers/dynamic_link_helper.dart';
import 'package:st/src/domain/repositories/route_repository.dart';

class RouteCompletionController extends Controller {
  RouteCompletionController(
    RouteRepository routeRepository,
    String routeId,
  )   : _routeRepository = routeRepository,
        routeId = routeId;

  RouteRepository _routeRepository;
  String routeId;
  String? link;
  bool isShareButtonEnabled = false;

  @override
  void initListeners() {}

  @override
  Future<void> onInitState() async {
    await shareLink();
    enableButton();
    super.onInitState();
  }

  Future<void> shareLink() async {
    link = await DynamicLinkHelper.buildDynamicLink([routeId]);
  }

  void enableButton() {
    isShareButtonEnabled = true;
    refreshUI();
  }
}