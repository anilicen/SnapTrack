// ignore_for_file: deprecated_member_use, unused_element

import 'package:flutter/material.dart' hide View;
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:flutter_svg/svg.dart';
import 'package:st/src/app/constants.dart';
import 'package:st/src/app/navigator.dart';
import 'package:st/src/app/pages/profile/profile_controller.dart';
import 'package:st/src/app/widgets/app_bar.dart';
import 'package:st/src/data/repositories/data_user_repository.dart';

class ProfileViewHolder extends StatefulWidget {
  const ProfileViewHolder({super.key});

  @override
  State<ProfileViewHolder> createState() => _ProfileViewHolderState();
}

class _ProfileViewHolderState extends State<ProfileViewHolder> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _ProfileView();
  }
}

class _ProfileView extends View {
  @override
  State<StatefulWidget> createState() {
    return _ProfileViewState(
      ProfileController(
        DataUserRepository(),
      ),
    );
  }
}

class _ProfileViewState extends ViewState<_ProfileView, ProfileController> {
  _ProfileViewState(ProfileController controller) : super(controller);

  @override
  Widget get view {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: globalKey,
      body: Column(
        children: [
          STAppBar(title: 'My Profile'),
          ControlledWidgetBuilder<ProfileController>(
            builder: (context, controller) {
              return controller.user == null
                  ? Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Expanded(
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        child: Container(
                          color: kBackgroundColor,
                          child: Column(
                            children: [
                              SizedBox(height: 10),
                              Container(
                                color: kWhite,
                                width: size.width,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: controller.pickImageAndUpdateProfile,
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 10, top: 10),
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          color: kPrimaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                        child: Stack(
                                          children: [
                                            Align(
                                              alignment: Alignment.center,
                                              child: controller.user!.profilePictureUrl != null
                                                  ? ClipOval(
                                                      child: Image.network(
                                                        controller.user!.profilePictureUrl!,
                                                        width: 120,
                                                        height: 120,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )
                                                  : Icon(
                                                      Icons.person,
                                                      color: kPrimaryColorPale,
                                                      size: 80,
                                                    ),
                                            ),
                                            Positioned(
                                              right: 0,
                                              bottom: 0,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: kBackgroundColor,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.add_a_photo,
                                                  color: kPrimaryColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        controller.user!.username,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              _ProfileItem(
                                text: 'My Routes',
                                iconPath: 'heart',
                                onTap: () {
                                  STNavigator.navigateToMyRoutesView(context);
                                },
                              ),
                              SizedBox(height: 10),
                              _ProfileItem(
                                text: 'Joined Challenges',
                                iconPath: 'star',
                                onTap: () {
                                  STNavigator.navigateToJoinedChallengesView(context);
                                },
                              ),
                              SizedBox(height: 10),
                              _ProfileItem(
                                text: 'Saved Challenges',
                                iconPath: 'bookmark',
                                onTap: () {
                                  STNavigator.navigateToSavedRoutesView(context);
                                },
                              ),
                              SizedBox(height: 10),
                              _ProfileItem(
                                text: 'Sign Out',
                                iconPath: 'sign_out',
                                onTap: controller.signOut,
                              ),
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

class _ProfileItem extends StatelessWidget {
  final String text;
  final String iconPath;
  final Function()? onTap;

  const _ProfileItem({
    Key? key,
    required this.text,
    required this.iconPath,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        color: kWhite,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/$iconPath.svg',
              height: 30,
              width: 30,
            ),
            SizedBox(width: 20),
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
