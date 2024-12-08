import 'package:st/src/domain/entities/challenge.dart';
import 'package:st/src/domain/entities/route.dart';

abstract class ChallengeRepository {
  Future<Challenge?> getChallenge(String routeId);
  Future<List<Route>?> getJoinedChallenges();
  Future<void> removeChallenge(String routeId);
  Future<void> startChallenge(String challengeId, String routeId);
  Future<void> completeCheckpoint(String challengeId, String checkpointId);
  Future<int> getImageSimilarityPercentage(String takenImagePath, String checkpointImageUrl);
}
