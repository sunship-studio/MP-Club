import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/widgets/circular_button.dart';

class CheckInDetails extends StatefulWidget {
  CheckInDetails({super.key});

  @override
  State<CheckInDetails> createState() => _CheckInDetailsState();
}

class _CheckInDetailsState extends State<CheckInDetails> {
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(
      text:
          "Feeling good today! Had a great workout session and looking forward to the next one.",
    );
  }

  bool _isEditing = false;
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      snap: true,
      snapSizes: [0.65, 0.7],
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.lightScaffoldColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            controller: controller,
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              Container(
                padding: EdgeInsets.only(left: horizontalPadding.w),
                child: Row(
                  children: [
                    Text(
                      "DETAILS CHECK-IN",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding.w,
                          vertical: 16.h,
                        ),
                        child: Icon(Icons.close, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 24.h),
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w),
                child: Column(
                  children: [
                    Gap(16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "165",
                          style: TextStyle(
                            color: AppColors.darkTextColor,
                            fontSize: 58.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                            letterSpacing: -1.8,
                            height: 1,
                          ),
                        ),
                        Gap(4),
                        Text(
                          "lbs",
                          style: TextStyle(
                            color: AppColors.greyTextColor.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                            letterSpacing: -0.6,
                          ),
                        ),
                      ],
                    ),
                    Gap(16.h),
                    Container(
                      width: double.infinity,

                      height: 176.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/images/training_plan.png'),
                        ),
                      ),
                    ),
                    Gap(12.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "Notes / Mood",
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.3,
                              color: AppColors.greyTextColor,
                            ),
                          ),
                          Gap(6.h),
                          TextField(
                            controller: _notesController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            enabled: _isEditing,
                            style: TextStyle(
                              fontSize: 16.sp,
                              height: 1.4,

                              color:
                                  _isEditing
                                      ? AppColors.darkTextColor
                                      : AppColors.darkTextColor.withValues(
                                        alpha: 0.7,
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gap(16.h),
                    CircularButton(
                      label: _isEditing ? "Save Changes" : "Edit Check-In",
                      dark: false,
                      onTap: () async {
                        setState(() {
                          _isEditing = !_isEditing;
                        });
                      },
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
