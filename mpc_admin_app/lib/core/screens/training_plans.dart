import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_admin_app/app/bloc/public_plans/cubit.dart';
import 'package:mpc_admin_app/app/bloc/public_plans/state.dart';
import 'package:mpc_admin_app/core/router/route_names.dart';
import 'package:mpc_admin_app/core/theme/app_colors.dart';
import 'package:mpc_admin_app/core/widgets/public_plans/plan_card.dart';

class TrainingPlansScreen extends StatefulWidget {
  const TrainingPlansScreen({super.key});

  @override
  State<TrainingPlansScreen> createState() => _TrainingPlansScreenState();
}

class _TrainingPlansScreenState extends State<TrainingPlansScreen> {
  void _navigateToEditor() {
    context.go(RouteNames.publicPlanEditor);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Public Training Plans',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontFamily: 'SF-Pro',
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                onPressed: _navigateToEditor,
                icon: Icon(
                  Icons.add_circle,
                  color: AppColors.blueColor,
                  size: 32.w,
                ),
              ),
            ],
          ),

          Expanded(
            child: BlocBuilder<PublicPlansCubit, PublicPlansState>(
              builder: (context, state) {
                if (state is PublicPlansLoading ||
                    state is PublicPlanUploading) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.blueColor),
                        if (state is PublicPlanUploading) ...[
                          Gap(12.h),
                          Text(
                            'Creating the training plan... be patient',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontFamily: 'SF-Pro',
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        Gap(100.h),
                      ],
                    ),
                  );
                } else if (state is PublicPlansError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${state.message}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: 'SF-Pro',
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Gap(16.h),
                        ElevatedButton(
                          onPressed: () {
                            context.read<PublicPlansCubit>().loadPlans();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blueColor,
                          ),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (state is PublicPlansLoaded) {
                  if (state.plans.isEmpty) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 100),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 64.w,
                              color: Colors.grey[300],
                            ),
                            Gap(16.h),
                            Text(
                              'No plans yet',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontFamily: 'SF-Pro',
                                color: Colors.grey[300],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Gap(8.h),
                            Text(
                              'Tap + to create your first plan',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: 'SF-Pro',
                                color: Colors.grey[300],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  if (state.plans.isNotEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        await context.read<PublicPlansCubit>().loadPlans();
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        itemCount: state.plans.length,
                        itemBuilder: (context, index) {
                          final plan = state.plans[index];
                          return PlanCard(
                            plan: plan,
                            onEdit: (updatedPlan) {
                              context.read<PublicPlansCubit>().updatePlan(
                                plan.id!,
                                updatedPlan,
                              );
                            },
                            onDelete: () {
                              context.read<PublicPlansCubit>().deletePlan(
                                plan.id!,
                              );
                            },
                          );
                        },
                      ),
                    );
                  }
                } else {
                  return Center(
                    child: Text(
                      'No data available',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontFamily: 'SF-Pro',
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }

                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}
