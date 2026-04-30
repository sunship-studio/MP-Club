import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionDetailsDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const SubscriptionDetailsDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  // Static subscription details
  static const String subscriptionTitle = 'MPC Elite Online Coaching';
  static const String subscriptionPrice = '€260.00';
  static const String subscriptionPeriod = '1 Month';
  static const String pricePerDay = '€8.67';
  static const String description =
      'Transform your fitness journey with personalized online coaching. Get custom training plans, nutrition guidance, progress tracking, and direct access to your dedicated coach—all in one app.';

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkScaffoldColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.lightScaffoldColor,
                borderRadius: BorderRadius.circular(16.r),
              ),

              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Subscription Details',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.black),
                    onPressed: onCancel,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subscription Title
                    _buildSection(
                      icon: Icons.workspace_premium,
                      title: 'Subscription',
                      content: subscriptionTitle,
                    ),
                    SizedBox(height: 20.h),

                    // Description
                    _buildSection(
                      icon: Icons.info_outline,
                      title: 'What You Get',
                      content: description,
                    ),
                    SizedBox(height: 20.h),

                    // Duration
                    _buildSection(
                      icon: Icons.calendar_today,
                      title: 'Subscription Period',
                      content:
                          '$subscriptionPeriod (Automatically renews monthly)',
                    ),
                    SizedBox(height: 20.h),

                    // Price
                    _buildSection(
                      icon: Icons.payments_outlined,
                      title: 'Price',
                      content: subscriptionPrice,
                    ),
                    SizedBox(height: 12.h),

                    // Price per unit
                    _buildSection(
                      icon: Icons.attach_money,
                      title: 'Price Per Day',
                      content: '$pricePerDay per day',
                    ),
                    SizedBox(height: 20.h),

                    // Auto-renewal notice
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.lightScaffoldColor,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.autorenew,
                            color: Colors.black.withOpacity(0.8),
                            size: 20.sp,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'This subscription automatically renews unless cancelled at least 24 hours before the end of the current period. You can manage your subscription in your Apple ID settings.',
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.8),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Legal Links
                    _buildLegalLinks(),
                  ],
                ),
              ),
            ),

            // Footer Buttons
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.lightScaffoldColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
              ),
              child: Column(
                children: [
                  // Confirm Button
                  _SubscribeButton(onConfirm: onConfirm),
                  SizedBox(height: 12.h),
                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: onCancel,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.7),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.5), size: 16.sp),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Text(
          content,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLegalLinks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Legal',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8.h),
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            children: [
              TextSpan(text: 'By subscribing, you agree to our '),
              TextSpan(
                text: 'Terms of Use',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
                recognizer:
                    TapGestureRecognizer()
                      ..onTap = () => _launchUrl(Constants.termsOfUseUrl),
              ),
              TextSpan(text: ' and '),
              TextSpan(
                text: 'Privacy Policy',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
                recognizer:
                    TapGestureRecognizer()
                      ..onTap = () => _launchUrl(Constants.privacyPolicyUrl),
              ),
              TextSpan(text: '.'),
            ],
          ),
        ),
      ],
    );
  }
}

class _SubscribeButton extends StatelessWidget {
  _SubscribeButton({super.key, required this.onConfirm});

  final VoidCallback onConfirm;

  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _isPressed = true;
      },
      onTapUp: (_) {
        _isPressed = false;
      },
      onTapCancel: () {
        _isPressed = false;
      },

      onTap: onConfirm,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: Duration(milliseconds: 100),
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 100),
          opacity: _isPressed ? 0.6 : 1.0,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              color: AppColors.darkTextColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Center(
              child: Text(
                "Subscribe Now",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
