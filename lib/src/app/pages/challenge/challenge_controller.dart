import 'package:collection/collection.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:st/src/app/navigator.dart';
import 'package:st/src/app/widgets/alert_dialog.dart';
import 'package:st/src/app/widgets/primary_popup.dart';
import 'package:st/src/data/helpers/geolocation_helper.dart';
import 'package:st/src/domain/entities/challenge.dart';
import 'package:st/src/domain/entities/checkpoint.dart';
import 'package:st/src/domain/repositories/challenge_repository.dart';
import 'package:flutter/material.dart';

class ChallengeController extends Controller {
  ChallengeController(
    ChallengeRepository challengeRepository,
    this.challenge,
    this.thresholdValue,
  ) : _challengeRepository = challengeRepository;

  ChallengeRepository _challengeRepository;

  final Challenge challenge;
  final int thresholdValue;

  bool loading = false;
  MapController mapController = MapController();
  PanelController panelController = PanelController();

  @override
  void initListeners() {}

  bool isCheckpointCompleted(String checkpointId) {
    return challenge.completedCheckpointIds.contains(checkpointId);
  }

  bool get isRouteCompleted {
    return challenge.completedCheckpointIds.length == challenge.route.checkpoints.length;
  }

  Checkpoint get nextCheckpoint {
    return challenge.route.checkpoints.firstWhereOrNull((e) => !isCheckpointCompleted(e.id)) ??
        challenge.route.checkpoints.last;
  }

  void completeCheckpoint() async {
    if (!await GeolocationHelper.isCloseEnough(nextCheckpoint.location, distance: 50)) {
      PrimaryPopup(
        title: 'SnapTrack',
        content:
            'You can’t complete a checkpoint here. In order to complete a checkpoint you should be at most 50 meters away from the checkpoint.',
        context: getContext(),
      ).showDefaultPopup();

      return;
    }

    if (isRouteCompleted) {
      STNavigator.navigateToChallengeCompletionView(getContext(), challenge.id);
      return;
    }

    loading = true;
    refreshUI();

    final takenImagePath = await STNavigator.navigateToSTCameraView(getContext(), nextCheckpoint.photoUrl);

    if (takenImagePath == null) {
      loading = false;
      refreshUI();

      return;
    }

    final isSimilar = await checkImagesSimilarity(takenImagePath!, getContext());
    if (!isSimilar) {
      loading = false;
      refreshUI();

      return;
    }

    final nextCheckpointId = nextCheckpoint.id;

    await _challengeRepository.completeCheckpoint(challenge.id, nextCheckpointId);

    challenge.completedCheckpointIds.add(nextCheckpointId);

    loading = false;
    refreshUI();
  }

  Future<void> skipCheckpoint() async {
    loading = true;
    refreshUI();
    final nextCheckpointId = nextCheckpoint.id;

    await _challengeRepository.completeCheckpoint(challenge.id, nextCheckpointId);

    challenge.completedCheckpointIds.add(nextCheckpointId);
    print("HERE THERE");
    loading = false;
    refreshUI();
    Navigator.pop(getContext());
  }

  // final ImagePicker _picker = ImagePicker();

  // Function to upload images and get similarity score
  Future<bool> checkImagesSimilarity(String takenImagePath, BuildContext context) async {
    String checkpointImageUrl = nextCheckpoint.photoUrl;

    // Display the images
    // TODO: Remove Image Picker, Use takenImagePath
    // var takenImageWidget = Image.file(File(takenImagePath));
    // final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    // File imageFile = File(pickedFile!.path);
    // var checkpointImageWidget = Image.network(checkpointImageUrl);

    final similarityPercentage =
        await _challengeRepository.getImageSimilarityPercentage(takenImagePath, checkpointImageUrl);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return similarityPercentage >= thresholdValue
            ? Container(
                height: 100,
                child: STAlertDialog.getSimilarImageDialog(
                    similarityPercentage, takenImagePath, checkpointImageUrl, context))
            : Container(
                height: 100,
                child: STAlertDialog.getNotSimilarImageDialog(
                    takenImagePath, checkpointImageUrl, context, skipCheckpoint));
      },
    );

    return similarityPercentage >= thresholdValue;
  }
}
