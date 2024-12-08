import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:st/src/app/widgets/app_bar.dart';
import 'package:st/src/app/widgets/primary_button.dart';

class RouteCompletionScreen extends StatelessWidget {
  final String? link;
  final bool isShareButtonEnabled;
  final String text;
  const RouteCompletionScreen({
    super.key,
    required this.link,
    required this.isShareButtonEnabled,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        STAppBarWithClose('SnapTrack'),
        SizedBox(height: 140),
        Container(
          width: 250,
          height: 250,
          child: Lottie.asset(
            'assets/animations/lottieCongrats.json',
          ),
        ),
        SizedBox(height: 51),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
        Spacer(),
        PrimaryButton(
          text: "Share Route Link",
          onPressed: () async {
            Share.share(
                "Get ready for an exciting challenge! I've just created a brand-new route in SnapTrack. Tap to join the thrill!\n\n" +
                    (link ?? " "));
          },
          isEnabled: isShareButtonEnabled,
          isLoading: link == null,
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
