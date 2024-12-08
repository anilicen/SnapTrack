import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:st/src/data/helpers/dynamic_link_helper.dart';
import 'package:st/src/domain/repositories/route_repository.dart';

class ChallengeCompletionController extends Controller {
  ChallengeCompletionController(RouteRepository routeRepository, String challengeId)
      : _routeRepository = routeRepository,
        challengeId = challengeId;

  // ignore: unused_field
  RouteRepository _routeRepository;
  String challengeId;
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
    link = await DynamicLinkHelper.buildDynamicLink([challengeId]);
  }

  void enableButton() {
    isShareButtonEnabled = true;
    refreshUI();
  }
}
