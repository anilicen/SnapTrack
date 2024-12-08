// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart' hide View hide Route;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:st/src/app/constants.dart';
import 'package:st/src/app/navigator.dart';
import 'package:st/src/app/pages/joined_challenges/joined_challenges_controller.dart';
import 'package:st/src/app/widgets/app_bar.dart';
import 'package:st/src/data/helpers/dynamic_link_helper.dart';
import 'package:st/src/data/repositories/data_challenge_repository.dart';
import 'package:st/src/data/utils/string_utils.dart';
import 'package:st/src/domain/entities/route.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:transparent_image/transparent_image.dart';

class JoinedChallengesView extends View {
  @override
  State<StatefulWidget> createState() {
    return _JoinedChallengesViewState(
      JoinedChallengesController(
        DataChallengeRepository(),
      ),
    );
  }
}

class _JoinedChallengesViewState extends ViewState<JoinedChallengesView, JoinedChallengesController> {
  _JoinedChallengesViewState(JoinedChallengesController controller) : super(controller);

  @override
  Widget get view {
    return Scaffold(
      body: Column(
        children: [
          STAppBarWithBack('Joined Challenges'),
          ControlledWidgetBuilder<JoinedChallengesController>(
            builder: (context, controller) {
              return controller.joinedChallenges == null
                  ? Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: 30),
                        physics: BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        child: Container(
                          color: kBackgroundColor,
                          child: Column(
                            children: [
                              for (Route route in controller.joinedChallenges!) _JoinedChallengesWidget(route: route),
                            ],
                          ),
                        ),
                      ),
                    );
            },
          ),
        ],
      ),
    );
  }
}

class _JoinedChallengesWidget extends StatelessWidget {
  const _JoinedChallengesWidget({
    required this.route,
  });

  final Route route;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        STNavigator.navigateToRouteDetailsView(route);
      },
      child: ControlledWidgetBuilder<JoinedChallengesController>(builder: (context, controller) {
        return Column(
          children: [
            SizedBox(height: 10),
            Slidable(
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) async {
                      final link = await DynamicLinkHelper.buildDynamicLink([route.id]);

                      Share.share(
                          "Get ready for an exciting challenge! This is an amazing route in SnapTrack. Tap to join the thrill!\n\n" +
                              link);
                    },
                    backgroundColor: Color(0xFF21B7CA),
                    foregroundColor: Colors.white,
                    icon: Icons.share,
                  ),
                  SlidableAction(
                    onPressed: (context) {
                      controller.removeJoinedChallenges(route);
                    },
                    backgroundColor: Colors.red,
                    icon: Icons.delete,
                  ),
                ],
              ),
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: FadeInImage.memoryNetwork(
                          fadeInDuration: kFadeInDuration,
                          placeholder: kTransparentImage,
                          image: route.coverPhotoUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      height: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            route.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                child: SvgPicture.asset(
                                  'assets/icons/checkpoint.svg',
                                  color: kPrimaryColor,
                                ),
                              ),
                              SizedBox(width: 3),
                              Container(
                                child: Text(
                                  route.checkpoints.length.toString() + " Checkpoints",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                child: SvgPicture.asset(
                                  'assets/icons/clock.svg',
                                  color: kPrimaryColor,
                                ),
                              ),
                              SizedBox(width: 3),
                              Container(
                                child: Text(
                                  StringUtils.formatRouteLengthShort(route.length) +
                                      ' · ' +
                                      StringUtils.formatRouteDurationShort(route.duration),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                child: SvgPicture.asset(
                                  'assets/icons/star.svg',
                                  color: kPrimaryColor,
                                ),
                              ),
                              SizedBox(width: 3),
                              Container(
                                child: Text(
                                  route.rating.toString() + " (" + route.participantCount.toString() + ")",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
