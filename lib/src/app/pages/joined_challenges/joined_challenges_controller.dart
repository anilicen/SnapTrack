import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:st/src/domain/entities/route.dart';
import 'package:st/src/domain/repositories/challenge_repository.dart';

class JoinedChallengesController extends Controller {
  JoinedChallengesController(
    ChallengeRepository challengeRepository,
  ) : _challengeRepository = challengeRepository;

  final ChallengeRepository _challengeRepository;

  List<Route>? joinedChallenges;

  @override
  void onInitState() {
    getJoinedChallenges();
    super.onInitState();
  }

  @override
  void initListeners() {}

  void getJoinedChallenges() async {
    joinedChallenges = await _challengeRepository.getJoinedChallenges();
    refreshUI();
  }

  void removeJoinedChallenges(Route route) async {
    await _challengeRepository.removeChallenge(route.id);
    joinedChallenges!.remove(route);
    refreshUI();
  }
}
