import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_admin_app/app/models/User.dart';
import 'package:mpc_admin_app/app/services/socket.dart';
import 'package:mpc_admin_app/core/router/route_names.dart';
import 'package:mpc_admin_app/core/screens/online_coaching.dart';
import 'package:mpc_admin_app/core/theme/app_colors.dart';
import 'package:mpc_admin_app/core/theme/design_system.dart';

class UserBox extends StatefulWidget {
  const UserBox({super.key, required this.user});

  final User user;

  @override
  State<UserBox> createState() => _UserBoxState();
}

class _UserBoxState extends State<UserBox> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: SocketService().getClientUnreadCountStream(widget.user.id),
      builder: (context, snapshot) {
        return Container(
          margin: const EdgeInsets.only(bottom: kSpacingMedium),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: kBorderRadiusCardAll,
            boxShadow: kShadowMedium(context),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: kSpacingLarge,
            vertical: kSpacingMedium,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,

                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "${widget.user.firstName} ${widget.user.lastName}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'SF-Pro',
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: kSpacingSmall,
                                ),
                                height: 18,
                                width: 1.5,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Text(
                                widget.user.age.toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'SF-Pro',
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 0),
                          Row(
                            children: [
                              Text(
                                widget.user.email.toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'SF-Pro',
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: kSpacingSmall),
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: IconButton(
                                  onPressed: () {
                                    print("Copy email: ${widget.user.email}");
                                    Clipboard.setData(
                                      ClipboardData(text: widget.user.email),
                                    );
                                  },
                                  icon: Icon(Coolicons.copy),
                                  iconSize: 20,
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.all<Color>(
                                          Theme.of(context).cardTheme.color ??
                                              Colors.white,
                                        ),
                                    padding: WidgetStateProperty.all<
                                      EdgeInsetsGeometry
                                    >(
                                      const EdgeInsets.symmetric(
                                        vertical: 0,
                                        horizontal: 0,
                                      ),
                                    ),

                                    shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder
                                    >(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          5.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const Spacer(),
                      snapshot.hasData && snapshot.data! > 0
                          ? Container(
                            padding: const EdgeInsets.all(kSpacingMedium),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red[700],
                            ),
                            child: Center(
                              child: Text(
                                "${snapshot.data}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'SF-Pro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                          : Container(),
                      const SizedBox(width: kSpacingMedium),
                      Icon(
                        isExpanded
                            ? Coolicons.chevron_big_down
                            : Coolicons.chevron_big_right,
                        size: 24,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 5),

              isExpanded
                  ? Container(
                    margin: const EdgeInsets.only(top: kSpacingSmall),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: kSpacingSmall),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                launchGmail(widget.user.email);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: kBorderRadiusMediumAll,
                                  boxShadow: kShadowLight(context),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: kSpacingSmall,
                                  horizontal: kSpacingMedium,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/gmail.png',
                                      width: 24,
                                      height: 24,
                                    ),
                                    const SizedBox(width: kSpacingSmall),
                                    Text(
                                      "Go to Gmail",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'SF-Pro',
                                        color:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                color:
                                    widget.user.status == "active"
                                        ? Colors.green.withValues(alpha: 0.8)
                                        : Colors.red.withValues(alpha: 0.8),
                                borderRadius: kBorderRadiusMediumAll,
                                boxShadow: kShadowLight(context),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: kSpacingSmall,
                                horizontal: kSpacingMedium,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    widget.user.status == "active"
                                        ? Coolicons.check
                                        : Coolicons.close_big,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    widget.user.status == "active"
                                        ? "Active"
                                        : "Inactive",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'SF-Pro',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: kSpacingSmall),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.push(
                                  RouteNames.chat,
                                  extra: widget.user,
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: kBorderRadiusMediumAll,
                                  boxShadow: kShadowLight(context),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: kSpacingSmall,
                                  horizontal: kSpacingMedium,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Coolicons.chat,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                    const SizedBox(width: kSpacingSmall),
                                    Text(
                                      "Chat",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'SF-Pro',
                                        color:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Spacer(),
                            snapshot.hasData && snapshot.data! > 0
                                ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: kSpacingSmall,
                                    vertical: kSpacingXSmall,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red[700],
                                    borderRadius: kBorderRadiusMediumAll,
                                  ),
                                  child: Text(
                                    "${snapshot.data} new messages",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'SF-Pro',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                                : Container(),
                          ],
                        ),
                        const SizedBox(height: kSpacingMedium),

                        Row(children: [TrainingPlanButton(user: widget.user)]),

                        const SizedBox(height: kSpacingMedium),

                        Row(children: [CheckInsButton(user: widget.user)]),
                        const SizedBox(height: kSpacingMedium),
                        Row(
                          children: [WorkoutHistoryButton(user: widget.user)],
                        ),
                        const SizedBox(height: kSpacingSmall),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Calories per day:",
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'SF-Pro',
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: kSpacingXSmall),
                            CaloriesSet(user: widget.user),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Weight goal:",
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'SF-Pro',
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: kSpacingXSmall),
                            WeightGoalSet(user: widget.user),
                          ],
                        ),
                      ],
                    ),
                  )
                  : Container(),
            ],
          ),
        );
      },
    );
  }
}

class TrainingPlanButton extends StatefulWidget {
  const TrainingPlanButton({super.key, this.user});

  final User? user;

  @override
  State<TrainingPlanButton> createState() => _TrainingPlanButtonState();
}

class _TrainingPlanButtonState extends State<TrainingPlanButton> {
  Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(RouteNames.planEditor, extra: widget.user);
      },
      onTapDown: (details) {
        setState(() {
          color = AppColors.blueColor.withOpacity(0.8);
        });
      },
      onTapUp: (details) {
        setState(() {
          color = null;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: color ?? AppColors.blueColor,
          borderRadius: kBorderRadiusMediumAll,
          boxShadow: kShadowLight(context),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: kSpacingSmall,
          horizontal: kSpacingMedium,
        ),
        child: Center(
          child: Text(
            "Edit training plan 🏋️‍♂️",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontFamily: 'SF-Pro',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class CheckInsButton extends StatefulWidget {
  const CheckInsButton({super.key, this.user});

  final User? user;

  @override
  State<CheckInsButton> createState() => _CheckInsButtonState();
}

class WorkoutHistoryButton extends StatefulWidget {
  const WorkoutHistoryButton({super.key, this.user});

  final User? user;

  @override
  State<WorkoutHistoryButton> createState() => _WorkoutHistoryButtonState();
}

class _WorkoutHistoryButtonState extends State<WorkoutHistoryButton> {
  Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(RouteNames.workoutHistory, extra: widget.user);
      },
      onTapDown: (details) {
        setState(() {
          color = AppColors.blueColor.withOpacity(0.8);
        });
      },
      onTapUp: (details) {
        setState(() {
          color = null;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: color ?? AppColors.blueColor,
          borderRadius: kBorderRadiusMediumAll,
          boxShadow: kShadowLight(context),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: kSpacingSmall,
          horizontal: kSpacingMedium,
        ),
        child: Center(
          child: Text(
            "Workout history 📈",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontFamily: 'SF-Pro',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckInsButtonState extends State<CheckInsButton> {
  Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(RouteNames.checkIns, extra: widget.user);
      },
      onTapDown: (details) {
        setState(() {
          color = AppColors.blueColor.withOpacity(0.8);
        });
      },
      onTapUp: (details) {
        setState(() {
          color = null;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: color ?? AppColors.blueColor,
          borderRadius: kBorderRadiusMediumAll,
          boxShadow: kShadowLight(context),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: kSpacingSmall,
          horizontal: kSpacingMedium,
        ),
        child: Center(
          child: Text(
            "View Check-Ins 📅",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontFamily: 'SF-Pro',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
