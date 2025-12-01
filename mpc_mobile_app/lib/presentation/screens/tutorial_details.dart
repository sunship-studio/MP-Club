import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/presentation/widgets/back_button.dart';

class TutorialDetailScreen extends StatelessWidget {
  const TutorialDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: topPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: AlignmentGeometry.bottomLeft,
                    child: MpcBackButton(color: Colors.black),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Tutorial Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(width: 48),
                ), // Placeholder for alignment
              ],
            ),
            Container(
              width: double.infinity,
              height: 243.h,
              color: Colors.grey[350],
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w),
              child: Text(
                "Tutorial Title",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 8.h),
            Text(""),
          ],
        ),
      ),
    );
  }
}
