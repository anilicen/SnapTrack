import 'package:flutter/material.dart' hide View;
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:st/src/app/constants.dart';
import 'package:st/src/app/pages/route_completion/route_completion_controller.dart';
import 'package:st/src/app/widgets/route_completion_screen.dart';
import 'package:st/src/data/repositories/data_route_repository.dart';

class RouteCompletionView extends View {
  final String routeId;
  RouteCompletionView(
    this.routeId,
  );

  @override
  State<StatefulWidget> createState() {
    return _RouteCompletionViewState(
      RouteCompletionController(
        DataRouteRepository(),
        routeId,
      ),
    );
  }
}

class _RouteCompletionViewState extends ViewState<RouteCompletionView, RouteCompletionController> {
  _RouteCompletionViewState(RouteCompletionController controller) : super(controller);

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
        child: ControlledWidgetBuilder<RouteCompletionController>(
          builder: (context, controller) {
            return RouteCompletionScreen(
              link: controller.link,
              isShareButtonEnabled: controller.isShareButtonEnabled,
              text: "You just created a new route! Share this adventure with your friends!",
            );
          },
        ),
      ),
    );
  }
}
