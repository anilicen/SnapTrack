import 'package:flutter/material.dart' hide View, Route;
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:st/src/app/constants.dart';
import 'package:st/src/app/navigator.dart';
import 'package:st/src/app/pages/enter_route_details/enter_route_details_controller.dart';
import 'package:st/src/app/widgets/st_text_field.dart';
import 'package:st/src/app/widgets/app_bar.dart';
import 'package:st/src/app/widgets/primary_button.dart';
import 'package:st/src/data/repositories/data_route_repository.dart';
import 'package:st/src/domain/entities/route.dart';
import 'package:transparent_image/transparent_image.dart';

class EnterRouteDetailsView extends View {
  EnterRouteDetailsView();

  @override
  State<StatefulWidget> createState() {
    return _EnterRouteDetailsViewState(
      EnterRouteDetailsController(
        DataRouteRepository(),
      ),
    );
  }
}

class _EnterRouteDetailsViewState extends ViewState<EnterRouteDetailsView, EnterRouteDetailsController> {
  _EnterRouteDetailsViewState(EnterRouteDetailsController controller) : super(controller);

  @override
  Widget get view {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      key: globalKey,
      backgroundColor: kWhite,
      resizeToAvoidBottomInset: false,
      body: Container(
        width: size.width,
        height: size.height,
        child: ControlledWidgetBuilder<EnterRouteDetailsController>(
          builder: (context, controller) {
            return Column(
              children: [
                STAppBarWithBack("Route Details"),
                SizedBox(height: 20),
                Container(
                  width: size.width - 40,
                  child: Text(
                    "Select Cover Photo",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  height: 140,
                  width: size.width,
                  child: controller.route == null
                      ? Container(
                          width: 30,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : ListView(
                          cacheExtent: 1650,
                          addAutomaticKeepAlives: false,
                          scrollDirection: Axis.horizontal,
                          children: [
                            SizedBox(width: 20),
                            for (int index = 0; index < controller.route!.checkpoints.length; index++)
                              RouteDetailsImage(
                                controller: controller,
                                index: index,
                              ),
                          ],
                        ),
                ),
                Container(
                  width: size.width - 40,
                  child: Text(
                    "Route Information",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                STTextField(
                  size: size,
                  title: "Route Name",
                  hintText: "A Route Name",
                  isObscure: false,
                  onChanged: controller.setRouteName,
                ),
                SizedBox(height: 30),
                Container(
                  width: size.width - 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 25,
                        width: 50,
                        child: Switch(
                          trackOutlineColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                            return kWhite;
                          }),
                          thumbColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                            return kWhite;
                          }),
                          activeColor: kPrimaryColor,
                          inactiveTrackColor: kDeactiveColor,
                          value: controller.isPrivate,
                          onChanged: controller.togglePrivate,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Private Route",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 35),
                if (controller.isPrivate)
                  Container(
                    width: size.width - 40,
                    child: Text(
                      "* If you enable private route, only people with the route link can join the challenge. The route link will be created at the next step.",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: kBlackHint,
                      ),
                    ),
                  ),
                Spacer(),
                PrimaryButton(
                  text: "Create Route",
                  onPressed: () async {
                    await controller.addRoute();
                    Route myRoute = controller.route!;
                    print("ID: ${myRoute.id}");
                    print("Name: ${myRoute.name}");
                    print("Cover Photo URL: ${myRoute.coverPhotoUrl}");
                    print("Checkpoints: ${myRoute.checkpoints}");
                    print("Path: ${myRoute.path}");
                    print("Duration: ${myRoute.duration}");
                    print("Is Private: ${myRoute.isPrivate}");
                    print("Share Link: ${myRoute.shareLink}");
                    print("Created By: ${myRoute.createdBy}");
                    print("Created At: ${myRoute.createdAt}");
                    print("Participant Count: ${myRoute.participantCount}");

                    STNavigator.navigateToRouteCompletionView(context, controller.routeId!);
                  },
                  isEnabled: controller.isRouteNameInitialized(),
                  isLoading: false,
                ),
                SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}

class RouteDetailsImage extends StatelessWidget {
  final EnterRouteDetailsController controller;
  final int index;
  const RouteDetailsImage({
    super.key,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => controller.selectIndex(index),
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ColorFiltered(
                colorFilter: index == controller.selectedIndex
                    ? ColorFilter.mode(
                        Colors.transparent,
                        BlendMode.multiply,
                      )
                    : ColorFilter.mode(
                        Colors.grey,
                        BlendMode.saturation,
                      ),
                child: FadeInImage.memoryNetwork(
                  fadeInDuration: kFadeInDuration,
                  placeholder: kTransparentImage,
                  image: controller.route!.checkpoints[index].photoUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 15),
      ],
    );
  }
}
