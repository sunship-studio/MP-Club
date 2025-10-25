import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_admin_app/app/models/User.dart';
import 'package:mpc_admin_app/app/services/socket.dart';
import 'package:mpc_admin_app/core/router/route_names.dart';
import 'package:mpc_admin_app/core/screens/online_coaching.dart';

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
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 6),
                                height: 18,
                                width: 1.5,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Text(
                                widget.user.age.toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'SF-Pro',
                                  color: Colors.black,
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
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 6),
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
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red[700],
                            ),
                            child: Center(
                              child: Text(
                                "${snapshot.data}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'SF-Pro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                          : Container(),
                      const SizedBox(width: 10),
                      Icon(
                        isExpanded
                            ? Coolicons.chevron_big_down
                            : Coolicons.chevron_big_right,
                        size: 24,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 5),

              isExpanded
                  ? Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                launchGmail(widget.user.email);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(227, 227, 227, 0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 10,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset('assets/gmail.png', width: 24),
                                    const SizedBox(width: 5),
                                    Text(
                                      "Go to Gmail",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'SF-Pro',
                                        color: Colors.black,
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
                                        ? Color.fromRGBO(44, 199, 46, 0.6)
                                        : Color.fromRGBO(255, 0, 0, 0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 10,
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
                                    style: TextStyle(
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
                        SizedBox(height: 8),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.go(RouteNames.chat, extra: widget.user);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(227, 227, 227, 0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 10,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Coolicons.chat,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "Chat",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'SF-Pro',
                                        color: Colors.black,
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red[700],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "${snapshot.data} new messages",
                                    style: TextStyle(
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
                        const SizedBox(height: 12),

                        Row(children: [TrainingPlanButton(user: widget.user)]),

                        const SizedBox(height: 12),

                        Row(children: [CheckInsButton(user: widget.user)]),
                        SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Calories per day:",
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'SF-Pro',
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
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
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
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
        context.go(RouteNames.planEditor, extra: widget.user);
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
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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

class _CheckInsButtonState extends State<CheckInsButton> {
  Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go(RouteNames.checkIns, extra: widget.user);
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
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
