import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_admin_app/app/models/PublicPlan.dart';
import 'package:mpc_admin_app/core/theme/app_colors.dart';
import 'package:mpc_admin_app/core/widgets/public_plans/edit_plan_dialog.dart';

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
            backgroundColor: AppColors.darkCardColor,
            title: Text(
              'Delete Plan',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'SF-Pro',
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Are you sure you want to delete "${plan.name}"?',
              style: TextStyle(color: Colors.white70, fontFamily: 'SF-Pro'),
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

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditPlanDialog(plan: plan, onSave: onEdit),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.darkCardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.lightCardColor2.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  plan.name,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontFamily: 'SF-Pro',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _showEditDialog(context),
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
          Gap(12.h),
          Row(
            children: [
              Icon(Icons.attach_money, color: Colors.green, size: 16.w),
              Gap(6.w),
              Text(
                '\$${plan.price.toStringAsFixed(2)}',
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
                '${plan.listOfExercises.length} exercises',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'SF-Pro',
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (plan.excelFileUrl.isNotEmpty) ...[
            Gap(8.h),
            Row(
              children: [
                Icon(Icons.insert_drive_file, color: Colors.green, size: 16.w),
                Gap(6.w),
                Expanded(
                  child: Text(
                    'Excel file attached',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'SF-Pro',
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (plan.listOfExercises.isNotEmpty) ...[
            Gap(12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children:
                  plan.listOfExercises.take(5).map((exercise) {
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
                        exercise,
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
            if (plan.listOfExercises.length > 5) ...[
              Gap(8.h),
              Text(
                '+${plan.listOfExercises.length - 5} more',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'SF-Pro',
                  color: Colors.white54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
