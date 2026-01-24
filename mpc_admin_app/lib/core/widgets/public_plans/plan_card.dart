import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_admin_app/app/models/PublicPlan.dart';
import 'package:mpc_admin_app/core/router/route_names.dart';
import 'package:mpc_admin_app/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class PlanCard extends StatelessWidget {
  final PublicPlan plan;
  final Function(PublicPlan) onEdit;
  final VoidCallback onDelete;

  const PlanCard({
    super.key,
    required this.plan,
    required this.onEdit,
    required this.onDelete,
  });

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.lightCardColor,
            title: Text(
              'Delete Plan',
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.7),
                fontFamily: 'SF-Pro',
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Are you sure you want to delete "${plan.name}"?',
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.7),
                fontFamily: 'SF-Pro',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onDelete();
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _navigateToEditor(BuildContext context) {
    context.push(RouteNames.publicPlanEditor, extra: plan);
  }

  Future<void> _openExcelFile() async {
    if (plan.excelFileUrl == null || plan.excelFileUrl!.isEmpty) return;
    final uri = Uri.parse(plan.excelFileUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.lightCardColor2.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan.name,
            style: TextStyle(
              fontSize: 24.sp,
              fontFamily: 'SF-Pro',
              color: Theme.of(context).textTheme.bodyLarge!.color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Gap(12.h),
          Row(
            children: [
              Text(
                '€ ${plan.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: 'SF-Pro',
                  color: Colors.green,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Gap(8.h),
          Row(
            children: [
              Icon(
                Icons.fitness_center,
                color: AppColors.blueColor,
                size: 16.w,
              ),
              Gap(6.w),
              Text(
                '${plan.days.length} training days',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'SF-Pro',
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          if (plan.days.isNotEmpty) ...[
            Gap(12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children:
                  plan.days.take(1).map((day) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blueColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        day.exercises.map((e) => e.name).join(', '),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: 'SF-Pro',
                          color: AppColors.blueColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
            ),
            if (plan.days.length > 1) ...[
              Gap(8.h),
              Text(
                '+${plan.days.length - 1} more',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'SF-Pro',
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
          Gap(12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (plan.excelFileUrl != null && plan.excelFileUrl!.isNotEmpty)
                IconButton(
                  onPressed: _openExcelFile,
                  icon: Icon(
                    Icons.table_chart,
                    color: Colors.green,
                    size: 20.w,
                  ),
                  tooltip: 'Open Excel file',
                ),
              IconButton(
                onPressed: () => _navigateToEditor(context),
                icon: Icon(
                  Icons.edit,
                  color: AppColors.blueColor,
                  size: 20.w,
                ),
              ),
              IconButton(
                onPressed: () => _showDeleteConfirmation(context),
                icon: Icon(Icons.delete, color: Colors.red, size: 20.w),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
