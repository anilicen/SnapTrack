import 'package:flutter/material.dart' hide View;
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:st/src/app/constants.dart';
import 'package:st/src/app/pages/challenge_completion/challenge_completion_controller.dart';
import 'package:st/src/app/widgets/route_completion_screen.dart';
import 'package:st/src/data/repositories/data_route_repository.dart';

class ChallengeCompletionView extends View {
  final String challengeId;
  ChallengeCompletionView(
    this.challengeId,
  );

  @override
  State<StatefulWidget> createState() {
    return _ChallengeCompletionViewState(
      ChallengeCompletionController(
        DataRouteRepository(),
        challengeId,
      ),
    );
  }
}

class _ChallengeCompletionViewState extends ViewState<ChallengeCompletionView, ChallengeCompletionController> {
  _ChallengeCompletionViewState(ChallengeCompletionController controller) : super(controller);

  @override
  Widget get view {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      key: globalKey,
      backgroundColor: kWhite,
      resizeToAvoidBottomInset: false,
      body: Container(
        height: size.height,
        width: size.width,
        child: ControlledWidgetBuilder<ChallengeCompletionController>(
          builder: (context, controller) {
            return RouteCompletionScreen(
              link: controller.link,
              isShareButtonEnabled: controller.isShareButtonEnabled,
              text: "You just finished a route! Share this adventure with your friends!",
            );
          },
        ),
      ),
    );
  }
}
