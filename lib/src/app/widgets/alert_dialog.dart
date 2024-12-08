import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:st/src/app/constants.dart';
import 'package:st/src/app/widgets/primary_button.dart';

class STAlertDialog {
  static AlertDialog getDeleteDialog(BuildContext context, Function func) {
    return AlertDialog(title: Text('Delete'), content: Text('Are you sure you want to delete?'), actions: [
      TextButton(
        child: Text('Cancel'),
        onPressed: () => Navigator.pop(context),
      ),
      TextButton(
          child: Text('Delete'),
          onPressed: () {
            func();
            Navigator.pop(context);
          }),
    ]);
  }

  static AlertDialog getImageDialog(String imagePath, String checkpointName) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: kWhite,
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(
            imagePath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  static Dialog getSimilarImageDialog(
      int similarityPercentage, String takenImagePath, String checkpointImagePath, BuildContext context) {
    return Dialog(
      backgroundColor: kWhite,
      surfaceTintColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: kBackgroundColor,
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Comparison",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(
              color: kBlack.withOpacity(0.09),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  child: Lottie.asset(
                    'assets/animations/greentick.json',
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            Text(
              "Images are similar: " + similarityPercentage.toString() + "%",
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
            SizedBox(height: 15),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          child: Image.file(
                            File(takenImagePath),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          color: Colors.red,
                          child: Image.network(
                            checkpointImagePath,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                PrimaryButton(
                    text: "Continue", onPressed: () => Navigator.pop(context), isEnabled: true, isLoading: false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Dialog getNotSimilarImageDialog(
      String takenImagePath, String checkpointImagePath, BuildContext context, Function() skipCheckpoint) {
    return Dialog(
      backgroundColor: kWhite,
      surfaceTintColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: kBackgroundColor,
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Comparison",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(
              color: kBlack.withOpacity(0.09),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 75,
                  width: 75,
                  child: Lottie.asset(
                    'assets/animations/redcross.json',
                  ),
                ),
              ],
            ),
            Text(
              "Images are not similar.",
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
            SizedBox(height: 15),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          child: Image.file(
                            File(takenImagePath),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          color: Colors.red,
                          child: Image.network(
                            checkpointImagePath,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 56,
                  child: PrimaryButton(
                    isEnabled: true,
                    text: 'Try Again',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    isLoading: false,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 56,
                  child: PrimaryButton(
                    isEnabled: true,
                    color: Colors.grey,
                    text: 'Skip Checkpoint',
                    onPressed: () {
                      skipCheckpoint();
                    },
                    isLoading: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
