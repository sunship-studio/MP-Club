import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:mpc_admin_app/app/models/User.dart';
import 'package:mpc_admin_app/app/models/checkin.dart';
import 'package:mpc_admin_app/core/theme/app_colors.dart';
import 'package:mpc_admin_app/core/widgets/check-ins/full_screen_image_viewer.dart';

class CheckInDetails extends StatefulWidget {
  const CheckInDetails({super.key, required this.checkIn, required this.user});
  final CheckIn checkIn;
  final User user;

  @override
  State<CheckInDetails> createState() => _CheckInDetailsState();
}

class _CheckInDetailsState extends State<CheckInDetails> {
  Widget _buildSection(String label, String? value) {
    if (value == null || value.isEmpty) return SizedBox.shrink();
    return Container(
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
            label,
            style: TextStyle(
              fontSize: 12,
              height: 1.3,
              color: AppColors.greyTextColor,
            ),
          ),
          Gap(6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.4,
              color: AppColors.darkTextColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.checkIn.allPhotos;
    final hasQuestionnaire = widget.checkIn.wellbeing != null;

    return DraggableScrollableSheet(
      initialChildSize: hasQuestionnaire ? 0.85 : (photos.isEmpty ? 0.45 : 0.65),
      minChildSize: 0.3,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: [0.65, 0.85, 0.95],
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.lightScaffoldColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: ListView(
            controller: controller,
            padding: EdgeInsets.zero,
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
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date
                    Text(
                      DateFormat('d MMM yyyy, HH:mm').format(widget.checkIn.date),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.greyTextColor,
                      ),
                    ),
                    Gap(16.h),

                    // Weight
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.checkIn.weight.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 50.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                            letterSpacing: -1.2,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Text(
                            "kg",
                            style: TextStyle(
                              color: AppColors.greyTextColor.withValues(alpha: 0.6),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Gap(16.h),

                    // Photos gallery (tappable for zoom)
                    if (photos.isNotEmpty) ...[
                      Text(
                        "Photos",
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.3,
                          color: AppColors.greyTextColor,
                        ),
                      ),
                      Gap(8.h),
                      SizedBox(
                        height: 176.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: photos.length,
                          separatorBuilder: (_, __) => Gap(8.w),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => FullScreenImageViewer(
                                      imageUrls: photos,
                                      initialIndex: index,
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.r),
                                child: Image.network(
                                  photos[index],
                                  height: 176.h,
                                  width: photos.length == 1
                                      ? MediaQuery.of(context).size.width - 50.w
                                      : 200.w,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Gap(12.h),
                    ],

                    // Questionnaire fields
                    if (widget.checkIn.wellbeing != null) ...[
                      _buildSection("How do you feel/overall well being?", widget.checkIn.wellbeing),
                      Gap(10.h),
                    ],
                    if (widget.checkIn.biggestWin != null) ...[
                      _buildSection("Biggest win from this week", widget.checkIn.biggestWin),
                      Gap(10.h),
                    ],
                    if (widget.checkIn.struggles != null) ...[
                      _buildSection("What did you struggle with most this week?", widget.checkIn.struggles),
                      Gap(10.h),
                    ],
                    if (widget.checkIn.questions != null) ...[
                      _buildSection("Do you have any questions?", widget.checkIn.questions),
                      Gap(10.h),
                    ],

                    // Notes / Mood (legacy or old check-ins)
                    if (widget.checkIn.note != null && widget.checkIn.note!.isNotEmpty)
                      _buildSection("Notes / Mood", widget.checkIn.note),

                    Gap(24.h),
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
