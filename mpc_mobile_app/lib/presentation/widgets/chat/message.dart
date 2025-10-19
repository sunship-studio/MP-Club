import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/presentation/widgets/fullscreen_image_viewer.dart';

class ChatMessage extends StatelessWidget {
  final bool isSentByMe;
  final String? replyTo;
  final String content;
  final String status;
  final String time;
  final Map<String, dynamic>? attachment;
  final bool isNextMessageFromSameSender;
  const ChatMessage({
    super.key,
    this.attachment,
    required this.isNextMessageFromSameSender,
    required this.content,
    this.isSentByMe = true,
    this.replyTo,
    required this.status,
    required this.time,
  });

  Widget _buildImageContent(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => FullScreenImageViewer(
                  imageUrl: attachment!['url'],
                  heroTag: "",
                ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: CachedNetworkImage(
          imageUrl: attachment!['url'],
          width: 200.w,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
          errorWidget:
              (context, url, error) => Container(
                width: 200.w,
                height: 200.w,
                color: Colors.grey[300],
                child: Icon(Icons.error),
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("attachment: $attachment");
    return Container(
      margin: EdgeInsets.only(top: isNextMessageFromSameSender ? 4.h : 12.h),
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
                bottomLeft: Radius.circular(isSentByMe ? 12.r : 0.r),
                bottomRight: Radius.circular(isSentByMe ? 0.r : 12.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (attachment != null) ...[
                  _buildImageContent(context),
                  SizedBox(height: 8.h),
                ],
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
                SizedBox(height: 2.h),
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
                            : Icons.done_all,
                        size: 12.w,
                        color:
                            status == "read"
                                ? Colors.blue
                                : Colors.white.withValues(alpha: 0.8),
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
