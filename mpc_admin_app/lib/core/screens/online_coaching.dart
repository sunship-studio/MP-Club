import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpc_admin_app/app/bloc/training%20plan/cubit.dart';
import 'package:mpc_admin_app/app/bloc/users/cubit.dart';
import 'package:mpc_admin_app/app/bloc/users/state.dart';
import 'package:mpc_admin_app/app/models/User.dart';
import 'package:mpc_admin_app/app/models/WaitingListEntry.dart';
import 'package:mpc_admin_app/core/injection/get_it.dart';
import 'package:mpc_admin_app/core/widgets/PlanEditor.dart';
import 'package:mpc_admin_app/core/widgets/UserBox.dart';
import 'package:mpc_admin_app/core/widgets/exerciseBox.dart';
import 'package:url_launcher/url_launcher.dart';

class OnlineCoaching extends StatelessWidget {
  OnlineCoaching({
    super.key,
    required this.togglePlanEditor,
    required this.changeScreen,
    required this.planEditor,
    this.user,
  });
  final Function togglePlanEditor;
  final Function changeScreen;
  bool planEditor;
  User? user;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UsersCubit>(
      create: (context) => UsersCubit()..loadUsers(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: BlocBuilder<UsersCubit, UsersState>(
          builder: (context, state) {
            if (state is UsersLoadingState) {
              return Center(
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 19, 157, 221),
                  strokeWidth: 2,
                ),
              );
            } else if (state is UsersErrorState) {
              return Center(
                child: Text(
                  "Contact Igor: ${state.error}",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'SF-Pro',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            } else if (state is UsersLoadedState) {
              if (state.currentSubscribers.isEmpty) {
                return Center(
                  child: Text(
                    "No entries found",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'SF-Pro',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }
              if (planEditor) {
                return BlocProvider(
                  create: (context) => TrainingPlanCubit()..init(user!),
                  child: PlanEditor(
                    user: user!,
                    togglePlanEditor: togglePlanEditor,
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<UsersCubit>().loadUsers();
                },
                child: ListView.builder(
                  padding: EdgeInsets.only(),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: state.currentSubscribers.length,
                  itemBuilder: (context, index) {
                    final subscriber = state.currentSubscribers[index];

                    return UserBox(
                      changeScreen: changeScreen,
                      user: subscriber,
                      togglePlanEditor: togglePlanEditor,
                    );
                  },
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
  TextEditingController _controller = TextEditingController();
  Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          isEditing
              ? Container(
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
