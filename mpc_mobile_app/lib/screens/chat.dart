import 'package:coolicons/coolicons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/widgets/profile_avatar.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white),

            child: Row(
              children: [
                GestureDetector(
                  onTap: () {},
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    padding: EdgeInsets.only(
                      right: horizontalPadding.w - 10.w,
                      left: horizontalPadding.w,
                      top: topPadding(context),
                      bottom: 16.h,
                    ),
                    child: Icon(
                      Coolicons.chevron_big_left,
                      size: 20.w,
                      color: AppColors.darkTextColor,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    top: topPadding(context),
                    bottom: 16.h,
                  ),
                  child: Row(
                    children: [
                      ProfileAvatar(radius: 20.w),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Shane Mahon",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkTextColor,
                            ),
                          ),

                          Text(
                            "Active 2m ago",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
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
          Expanded(
            child: Container(
              child: ListView(
                children: [
                  DayDivider(),
                  ChatMessage(
                    content: "Hi i love the new workout plan!",
                    status: "delivered",
                    time: "12:30 PM",
                  ),
                  ChatMessage(
                    content: "Glad to hear that! Any questions so far?",
                    isSentByMe: false,
                    status: "read",
                    time: "12:31 PM",
                    replyTo: "Hi i love the new workout plan!",
                    
                  ),
                ],
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding.w,
                  vertical: 10.h,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: horizontalPadding.w,
              right: horizontalPadding.w,
              bottom: 30.h,
              top: 10.h,
            ),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        child: TextField(
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.darkTextColor,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 2.h),
                            border: InputBorder.none,
                            hintText: "Type a message...",
                            hintStyle: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.darkTextColor.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Gap(8.w),
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.blueColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        CupertinoIcons.paperplane,
                        size: 20.w,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      child: Icon(
                        CupertinoIcons.camera,
                        size: 20.w,
                        color: AppColors.darkTextColor.withValues(alpha: 0.5),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.w),
                      child: Icon(
                        CupertinoIcons.paperclip,
                        size: 20.w,
                        color: AppColors.darkTextColor.withValues(alpha: 0.5),
                      ),
                    ),
                    Gap(12.w),
                    Text(
                      "Submit check-in 📝",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blueColor.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage({
    super.key,
    required this.content,
    this.isSentByMe = true,
    this.replyTo,
    required this.status,
    required this.time,
  });

  bool isSentByMe = true;
  String? replyTo;
  String content;
  String status;
  String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment:
            isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (replyTo != null)
            Container(
              padding: EdgeInsets.all(8.w),
              margin: EdgeInsets.only(
                bottom: 4.h,
                left: isSentByMe ? 50.w : 0,
                right: isSentByMe ? 0 : 50.w,
              ),
              decoration: BoxDecoration(
                color: AppColors.lightCardColor2.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.reply,
                    size: 12.w,
                    color: AppColors.darkTextColor.withValues(alpha: 0.7),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    replyTo!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkTextColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: EdgeInsets.all(12.w),
            margin: EdgeInsets.only(
              left: isSentByMe ? 50.w : 0,
              right: isSentByMe ? 0 : 50.w,
            ),
            decoration: BoxDecoration(
              color:
                  isSentByMe
                      ? AppColors.blueColor.withValues(alpha: 0.9)
                      : AppColors.lightCardColor2,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
                bottomLeft: Radius.circular(
                  isSentByMe ? 12.r : 0.r,
                ), // Tail effect
                bottomRight: Radius.circular(
                  isSentByMe ? 0.r : 12.r,
                ), // Tail effect
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color:
                        isSentByMe
                            ? Colors.white
                            : AppColors.darkTextColor.withValues(alpha: 0.9),
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        color:
                            isSentByMe
                                ? Colors.white.withValues(alpha: 0.8)
                                : AppColors.darkTextColor.withValues(
                                  alpha: 0.6,
                                ),
                      ),
                    ),
                    if (isSentByMe) ...[
                      SizedBox(width: 4.w),
                      Icon(
                        status == "sent"
                            ? Icons.check
                            : status == "delivered"
                            ? Icons.done_all
                            : Icons.done_all, // read
                        size: 12.w,
                        color:
                            status == "read"
                                ? Colors.blue
                                : isSentByMe
                                ? Colors.white.withValues(alpha: 0.8)
                                : AppColors.darkTextColor.withValues(
                                  alpha: 0.6,
                                ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DayDivider extends StatelessWidget {
  const DayDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.dividerColor)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            "Today",
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.darkTextColor.withValues(alpha: 0.5),
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppColors.dividerColor)),
      ],
    );
  }
}
