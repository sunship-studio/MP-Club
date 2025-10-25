import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_admin_app/app/bloc/training%20plan/cubit.dart';
import 'package:mpc_admin_app/app/bloc/users/cubit.dart';
import 'package:mpc_admin_app/app/bloc/users/state.dart';
import 'package:mpc_admin_app/app/models/User.dart';
import 'package:mpc_admin_app/app/models/checkin.dart';
import 'package:mpc_admin_app/core/router/route_names.dart';
import 'package:mpc_admin_app/core/theme/app_colors.dart';
import 'package:mpc_admin_app/core/widgets/PlanEditor.dart';
import 'package:mpc_admin_app/core/widgets/UserBox.dart';
import 'package:mpc_admin_app/core/widgets/check-ins/checkpoint_card.dart';
import 'package:mpc_admin_app/core/widgets/check-ins/details.dart';
import 'package:url_launcher/url_launcher.dart';

class OnlineCoaching extends StatelessWidget {
  const OnlineCoaching({
    super.key,
    this.planEditor = false,
    this.checkIns = false,
    this.user,
  });

  final bool checkIns;
  final bool planEditor;
  final User? user;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UsersCubit>(
      create: (context) => UsersCubit()..loadUsers(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        child: BlocBuilder<UsersCubit, UsersState>(
          builder: (context, state) {
            if (state is UsersErrorState) {
              return Center(
                child: Text(
                  "Contact Igor: ${state.error}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'SF-Pro',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            } else if (state is UsersLoadedState ||
                state is UsersLoadingState) {
              if (checkIns) {
                return Checkpoints(user: user!);
              }
              if (planEditor) {
                return BlocProvider(
                  create: (context) => TrainingPlanCubit()..init(user!),
                  child: PlanEditor(user: user!),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<UsersCubit>().loadUsers();
                },
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "CURRENT SUBSCRIBERS",
                          style: TextStyle(
                            color: AppColors.lightTextColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                            letterSpacing: -0.4,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () {
                            context.read<UsersCubit>().loadUsers();
                          },
                          icon: Icon(
                            Coolicons.refresh,
                            color: AppColors.lightTextColor,
                            size: 20.w,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.go(RouteNames.addSubscriber);
                          },
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.black87,
                            ),
                            child: Icon(
                              Coolicons.plus,
                              color: AppColors.lightTextColor,
                              size: 20.w,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (state is UsersLoadingState) ...[
                      Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 19, 157, 221),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ] else if (state is UsersLoadedState) ...[
                      if (state.currentSubscribers.isEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 50.h),
                          child: Text(
                            "No subscribers found",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontFamily: 'SF-Pro',
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(),
                          shrinkWrap: true,
                          itemCount: state.currentSubscribers.length,
                          itemBuilder: (context, index) {
                            final subscriber = state.currentSubscribers[index];

                            return UserBox(user: subscriber);
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}

Future<void> launchGmail(String email) async {
  // Try different approaches based on platform
  try {
    // Android-specific Gmail intent
    final Uri androidGmailUri = Uri.parse(
      'googlegmail://compose?to=$email&subject=Regarding+your+training+application',
    );

    if (await canLaunchUrl(androidGmailUri)) {
      await launchUrl(androidGmailUri);
      return;
    }

    // iOS-specific Gmail URL scheme
    final Uri iosGmailUri = Uri.parse(
      'googlemail://co?to=$email&subject=Regarding+your+training+application',
    );

    if (await canLaunchUrl(iosGmailUri)) {
      await launchUrl(iosGmailUri);
      return;
    }

    // Last resort fallback to general mailto
    final Uri mailtoUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'Regarding your training application'},
    );

    if (!await launchUrl(mailtoUri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch any email client');
    }
  } catch (e) {
    print('Error launching Gmail: $e');
    // Show error to user
  }
}

class CaloriesSet extends StatefulWidget {
  const CaloriesSet({super.key, required this.user});
  final User user;
  @override
  State<CaloriesSet> createState() => _CaloriesSetState();
}

class _CaloriesSetState extends State<CaloriesSet> {
  bool isEditing = false;
  final TextEditingController _controller = TextEditingController();
  Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          isEditing
              ? SizedBox(
                width: 70,
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'SF-Pro',
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),

                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 0,
                    ),

                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontFamily: 'SF-Pro',
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                    border: InputBorder.none,
                    hintText:
                        widget.user.caloriesPerDay == null
                            ? "Enter calories"
                            : widget.user.caloriesPerDay.toString(),
                  ),
                ),
              )
              : Text(
                widget.user.caloriesPerDay == null
                    ? "Not set"
                    : widget.user.caloriesPerDay.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'SF-Pro',
                  color:
                      widget.user.caloriesPerDay == null
                          ? Colors.red[800]
                          : Colors.black,
                  fontWeight:
                      widget.user.caloriesPerDay == null
                          ? FontWeight.w700
                          : FontWeight.w600,
                ),
              ),
          !isEditing ? const SizedBox(width: 10) : Container(width: 2),
          GestureDetector(
            onTap: () {
              setState(() {
                isEditing = !isEditing;
              });

              if (!isEditing) {
                int? newCalories;
                if (_controller.text.isNotEmpty) {
                  newCalories = int.tryParse(_controller.text);
                } else {
                  newCalories = null;
                }
                context.read<UsersCubit>().saveCalorieGoal(
                  widget.user.id,
                  newCalories!,
                );
              }
            },
            onTapDown: (details) {
              setState(() {
                color = Theme.of(context).primaryColor.withOpacity(0.8);
              });
            },
            onTapUp: (details) {
              setState(() {
                color = null;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: color ?? Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: EdgeInsets.all(4),
                child:
                    isEditing
                        ? Icon(Coolicons.check, size: 20, color: Colors.white)
                        : Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Icon(
                            Coolicons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeightGoalSet extends StatefulWidget {
  const WeightGoalSet({super.key, required this.user});
  final User user;
  @override
  State<WeightGoalSet> createState() => _WeightGoalSetState();
}

class _WeightGoalSetState extends State<WeightGoalSet> {
  bool isEditing = false;
  final TextEditingController _controller = TextEditingController();
  Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          isEditing
              ? SizedBox(
                width: 70,
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'SF-Pro',
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),

                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 0,
                    ),

                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontFamily: 'SF-Pro',
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                    border: InputBorder.none,
                    hintText:
                        widget.user.targetWeight == null
                            ? "Enter weight goal"
                            : widget.user.targetWeight.toString(),
                  ),
                ),
              )
              : Text(
                widget.user.targetWeight == null
                    ? "Not set"
                    : widget.user.targetWeight.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'SF-Pro',
                  color:
                      widget.user.targetWeight == null
                          ? Colors.red[800]
                          : Colors.black,
                  fontWeight:
                      widget.user.targetWeight == null
                          ? FontWeight.w700
                          : FontWeight.w600,
                ),
              ),
          !isEditing ? const SizedBox(width: 10) : Container(width: 2),
          GestureDetector(
            onTap: () {
              setState(() {
                isEditing = !isEditing;
              });

              if (!isEditing) {
                int? newCalories;
                if (_controller.text.isNotEmpty) {
                  newCalories = int.tryParse(_controller.text);
                } else {
                  newCalories = null;
                }
                context.read<UsersCubit>().saveWeightGoal(
                  widget.user.id,
                  double.tryParse(_controller.text) ?? 0,
                );
              }
            },
            onTapDown: (details) {
              setState(() {
                color = Theme.of(context).primaryColor.withOpacity(0.8);
              });
            },
            onTapUp: (details) {
              setState(() {
                color = null;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: color ?? Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: EdgeInsets.all(4),
                child:
                    isEditing
                        ? Icon(Coolicons.check, size: 20, color: Colors.white)
                        : Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Icon(
                            Coolicons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Checkpoints extends StatelessWidget {
  const Checkpoints({super.key, required this.user});

  final User user;

  Future<void> _showDetailsModal(
    BuildContext context,
    CheckIn checkIn,
    User user,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: true,
        builder: (context) => CheckInDetails(checkIn: checkIn, user: user),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "${user.firstName.toUpperCase()} CHECKPOINTS",
                style: TextStyle(
                  color: AppColors.lightTextColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          if (user.checkIns.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 50.h),
                  child: Text(
                    "No check-ins available",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontFamily: 'SF-Pro',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 8.h),
              itemCount: user.checkIns.length,
              itemBuilder: (context, index) {
                final checkIn = user.checkIns.reversed.toList()[index];
                return CheckpointCard(
                  onTap: () {
                    _showDetailsModal(context, checkIn, user);
                  },
                  checkIn: checkIn,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
