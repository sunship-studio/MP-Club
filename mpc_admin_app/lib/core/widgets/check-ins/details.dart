import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_admin_app/app/models/User.dart';
import 'package:mpc_admin_app/app/models/checkin.dart';
import 'package:mpc_admin_app/core/theme/app_colors.dart';

class CheckInDetails extends StatefulWidget {
  CheckInDetails({super.key, required this.checkIn, required this.user});
  CheckIn checkIn;
  User user;

  @override
  State<CheckInDetails> createState() => _CheckInDetailsState();
}

class _CheckInDetailsState extends State<CheckInDetails> {
  late TextEditingController _notesController;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.checkIn.note ?? '');
    _weightController = TextEditingController(
      text: widget.checkIn.weight.toStringAsFixed(0),
    );
  }

  final bool _isEditing = false;
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: widget.checkIn.imageUrl == null ? 0.45 : 0.65,
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
                padding: EdgeInsets.only(left: 25.w),
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
                          horizontal: 25.w,
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
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                child: Column(
                  children: [
                    Gap(16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 50.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Inter',
                              letterSpacing: -1.2,
                            ),
                            enabled: _isEditing,

                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),

                        Text(
                          "kg",
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
                    if (widget.checkIn.imageUrl != null)
                      Container(
                        width: double.infinity,

                        height: 176.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(widget.checkIn.imageUrl!),
                          ),
                        ),
                      ),
                    if (widget.checkIn.imageUrl != null) Gap(12.h),
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
