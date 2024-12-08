// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:st/src/app/constants.dart';

class PrimaryIconButton extends StatelessWidget {
  final Function() onPressed;
  final String iconPath;
  final bool backgroundEnabled;
  final Color color;

  const PrimaryIconButton({
    super.key,
    required this.onPressed,
    this.iconPath = 'assets/icons/close.svg',
    this.backgroundEnabled = true,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: backgroundEnabled ? kWhite.withOpacity(0.9) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            if (backgroundEnabled)
              BoxShadow(
                blurRadius: 13,
                spreadRadius: 5,
                color: kBlack.withOpacity(0.12),
              )
          ],
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          iconPath,
          width: 30,
          height: 30,
          color: color,
        ),
      ),
    );
  }
}
