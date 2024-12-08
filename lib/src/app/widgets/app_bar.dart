// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:st/src/app/constants.dart';
import 'package:st/src/app/pages/core/core_controller.dart';
import 'package:st/src/app/pages/core/core_view.dart';
import 'package:st/src/app/pages/routes/routes_controller.dart';
import 'package:st/src/app/widgets/action_bar.dart';
import 'package:st/src/app/widgets/filter_bar.dart';
import 'package:st/src/app/widgets/rating_filter.dart';
import 'package:st/src/domain/types/sort_by.dart';

class STAppBar extends StatelessWidget {
  final String title;

  const STAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    EdgeInsets padding = MediaQuery.of(context).padding;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.center,
          color: kWhite,
          width: size.width,
          height: padding.top + 60,
          padding: EdgeInsets.only(top: padding.top, left: 19, right: 19),
          child: Text(
            title,
            style: kAppBarTitleStyle(),
          ),
        ),
      ],
    );
  }
}

class STAppBarWithBack extends StatefulWidget {
  final String title;

  STAppBarWithBack(this.title);

  @override
  _STAppBarWithBackState createState() => _STAppBarWithBackState();
}

class _STAppBarWithBackState extends State<STAppBarWithBack> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    EdgeInsets padding = MediaQuery.of(context).padding;
    return Container(
      color: kWhite,
      width: size.width,
      height: padding.top + 60,
      padding: EdgeInsets.only(top: padding.top),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: SvgPicture.asset(
              'assets/icons/arrow-back.svg',
              color: Colors.black,
              height: 20,
            ),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          Text(
            widget.title,
            style: kAppBarTitleStyle(),
          ),
          IconButton(
            onPressed: null,
            icon: SvgPicture.asset(
              'assets/icons/arrow-back.svg',
              color: Colors.transparent,
              height: 20,
            ),
            splashColor: Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class STAppBarWithClose extends StatefulWidget {
  final String title;

  STAppBarWithClose(this.title);

  @override
  _STAppBarWithCloseState createState() => _STAppBarWithCloseState();
}

class _STAppBarWithCloseState extends State<STAppBarWithClose> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    EdgeInsets padding = MediaQuery.of(context).padding;
    return Container(
      color: kWhite,
      width: size.width,
      height: padding.top + 60,
      padding: EdgeInsets.only(top: padding.top),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                CupertinoPageRoute(
                  builder: (context) => CoreView(),
                ),
                (_) => false,
              );
            },
            icon: SvgPicture.asset(
              'assets/icons/close.svg',
              color: Colors.black,
              height: 30,
            ),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          Text(
            widget.title,
            style: kAppBarTitleStyle(),
          ),
          IconButton(
            onPressed: null,
            icon: SvgPicture.asset(
              'assets/icons/close.svg',
              color: Colors.transparent,
              height: 30,
            ),
            splashColor: Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class STAppBarWithFilter extends StatefulWidget {
  final String title;
  final RoutesController controller;

  STAppBarWithFilter(
    this.title,
    this.controller,
  );

  @override
  _STAppBarWithFilterState createState() => _STAppBarWithFilterState();
}

class _STAppBarWithFilterState extends State<STAppBarWithFilter> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    EdgeInsets padding = MediaQuery.of(context).padding;
    return Container(
      color: kWhite,
      width: size.width,
      height: padding.top + 60,
      padding: EdgeInsets.only(top: padding.top),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: null,
            icon: SvgPicture.asset(
              'assets/icons/filter-sort.svg',
              color: Colors.transparent,
              height: 30,
            ),
            splashColor: Colors.transparent,
          ),
          Text(
            widget.title,
            style: kAppBarTitleStyle(),
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                context: CoreController().coreContext,
                builder: (context) {
                  return Container(
                    height: size.height * 0.8,
                    child: FilterAndSortWidget(routesController: widget.controller),
                  );
                },
              );
            },
            icon: SvgPicture.asset(
              'assets/icons/filter-sort.svg',
              color: Colors.black,
              height: 30,
            ),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class FilterAndSortWidget extends StatefulWidget {
  const FilterAndSortWidget({
    super.key,
    required this.routesController,
  });

  final RoutesController routesController;

  @override
  State<FilterAndSortWidget> createState() => _FilterAndSortWidgetState();
}

class _FilterAndSortWidgetState extends State<FilterAndSortWidget> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 20),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: kBlack.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              cacheExtent: 1650,
              addAutomaticKeepAlives: false,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ListTile(
                        dense: true,
                        title: Text(
                          'Sort',
                          style: kAppBarTitleStyle(),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          widget.routesController.sortBy = null;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: Text(
                          "Clear",
                          style: kSubtitleStyle(),
                        ),
                      ),
                    ),
                  ],
                ),
                RadioListTile(
                  contentPadding: EdgeInsets.only(left: 8),
                  title: Text('Most Rating'),
                  value: SortBy.highestRating,
                  groupValue: widget.routesController.sortBy,
                  onChanged: (value) {
                    setState(() {
                      widget.routesController.updateSortBy(value!);
                    });
                  },
                ),
                RadioListTile(
                  contentPadding: EdgeInsets.only(left: 8),
                  title: Text('Most Popular'),
                  value: SortBy.highestParticipation,
                  groupValue: widget.routesController.sortBy,
                  onChanged: (value) {
                    setState(() {
                      widget.routesController.updateSortBy(value!);
                    });
                  },
                ),
                RadioListTile(
                  contentPadding: EdgeInsets.only(left: 8),
                  title: Text('Recently Added'),
                  value: SortBy.newlyAdded,
                  groupValue: widget.routesController.sortBy,
                  onChanged: (value) {
                    setState(() {
                      widget.routesController.updateSortBy(value!);
                    });
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        child: ListTile(
                          title: Text(
                            'Filter',
                            style: kAppBarTitleStyle(),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          widget.routesController.filterBy.length = 0.0;
                          widget.routesController.filterBy.duration = 0.0;
                          widget.routesController.filterBy.rating = 0;
                          widget.routesController.filterBy.range = 0.0;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: Text(
                          "Clear",
                          style: kSubtitleStyle(),
                        ),
                      ),
                    ),
                  ],
                ),
                ListTile(
                  title: FilterBar(
                    title: "Minimum Length",
                    filterValue: widget.routesController.filterBy.length ?? 0.0,
                    barWidth: size.width - 80,
                    barHeight: 30,
                    scale: 20,
                    onChanged: (length) {
                      setState(() {
                        widget.routesController.filterBy.length = length;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: FilterBar(
                    title: "Minimum Duration",
                    filterValue: widget.routesController.filterBy.duration ?? 0,
                    barWidth: size.width - 80,
                    scale: 5,
                    barHeight: 30,
                    onChanged: (duration) {
                      setState(() {
                        widget.routesController.filterBy.duration = duration;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: FilterBar(
                    title: "Range",
                    filterValue: widget.routesController.filterBy.range ?? 0,
                    barWidth: size.width - 80,
                    scale: 20,
                    barHeight: 30,
                    onChanged: (range) {
                      setState(() {
                        widget.routesController.filterBy.range = range;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: RatingFilter(
                    rating: (widget.routesController.filterBy.rating ?? 0).toInt(),
                    onChanged: (rating) {
                      setState(() {
                        widget.routesController.filterBy.rating = rating;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          ActionBar(
            text: 'Apply',
            onPressed: () {
              widget.routesController.filterAndSortRoutes(reset: true);
              Navigator.pop(context);
            },
            isButtonEnabled: true,
            isButtonLoading: false,
          ),
        ],
      ),
    );
  }
}
