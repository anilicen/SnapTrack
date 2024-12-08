// ignore_for_file: deprecated_member_use

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart' hide View hide Route;
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:st/src/app/constants.dart';
import 'package:st/src/app/navigator.dart';
import 'package:st/src/app/widgets/app_bar.dart';
import 'package:st/src/app/widgets/st_search_bar.dart';
import 'package:st/src/data/utils/string_utils.dart';
import 'package:st/src/data/repositories/data_route_repository.dart';
import 'package:flutter_svg/svg.dart';
import 'routes_controller.dart';
import 'package:st/src/domain/entities/route.dart';
import 'package:transparent_image/transparent_image.dart';

class RoutesViewHolder extends StatefulWidget {
  const RoutesViewHolder({super.key});

  @override
  State<RoutesViewHolder> createState() => _RoutesViewHolderState();
}

class _RoutesViewHolderState extends State<RoutesViewHolder> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _RoutesView();
  }
}

class _RoutesView extends View {
  @override
  State<StatefulWidget> createState() {
    return _RoutesViewState(
      RoutesController(
        DataRouteRepository(),
      ),
    );
  }
}

class _RoutesViewState extends ViewState<_RoutesView, RoutesController> {
  _RoutesViewState(RoutesController controller) : super(controller);

  // TODO: Implement a refresh method
  @override
  Widget get view {
    Size size = MediaQuery.of(context).size;
    return ControlledWidgetBuilder<RoutesController>(
      builder: (context, controller) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              STAppBarWithFilter('Routes', controller),
              Container(
                width: size.width,
                color: kWhite,
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: STSearchBar(
                  hintText: 'Search Route',
                  onSearched: controller.searchRoutes,
                  onCleared: () => controller.searchRoutes(''),
                ),
              ),
              Expanded(
                child: Container(
                  width: size.width,
                  child: CustomMaterialIndicator(
                    onRefresh: () async => controller.refresh(),
                    indicatorBuilder: (context, controller) {
                      return Container(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(strokeWidth: 3),
                      );
                    },
                    child: PagedListView<int, dynamic>(
                      padding: EdgeInsets.only(bottom: 30),
                      physics: BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      pagingController: controller.pagingController,
                      builderDelegate: PagedChildBuilderDelegate<dynamic>(
                        itemBuilder: (context, item, index) {
                          return _RouteWidget(route: item);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RouteWidget extends StatelessWidget {
  const _RouteWidget({
    required this.route,
  });

  final Route route;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ControlledWidgetBuilder<RoutesController>(
      builder: (context, controller) {
        return GestureDetector(
          onTap: () {
            STNavigator.navigateToRouteDetailsView(
              route,
            );
          },
          child: Column(
            children: [
              SizedBox(height: 10),
              Container(
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
                      width: size.width - 130,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    route.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 30,
                                  width: 30,
                                  child: controller.isSavedRoute(route)
                                      ? GestureDetector(
                                          child: SvgPicture.asset(
                                            'assets/icons/bookmark.svg',
                                            color: kPrimaryColor,
                                          ),
                                          onTap: () {
                                            controller.removeSavedRoute(route);
                                          },
                                        )
                                      : GestureDetector(
                                          child: SvgPicture.asset(
                                            'assets/icons/bookmark-outlined.svg',
                                            color: kDeactiveColor,
                                          ),
                                          onTap: () {
                                            controller.addSavedRoute(route);
                                          },
                                        ),
                                ),
                              ],
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
            ],
          ),
        );
      },
    );
  }
}
