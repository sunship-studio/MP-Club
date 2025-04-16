import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpc_mobile_app/app/bloc/online_coaching/cubit.dart';
import 'package:mpc_mobile_app/app/bloc/online_coaching/state.dart';
import 'package:mpc_mobile_app/app/models/CurrentSubcriber.dart';
import 'package:mpc_mobile_app/app/models/WaitingListEntry.dart';
import 'package:url_launcher/url_launcher.dart';

class OnlineCoaching extends StatelessWidget {
  const OnlineCoaching({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnlineCoachingCubit>(
      create: (context) => OnlineCoachingCubit()..loadCurrentSubscribers(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: BlocBuilder<OnlineCoachingCubit, OnlineCoachingState>(
          builder: (context, state) {
            if (state is OnlineCoachingLoadingState) {
              return Center(
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 19, 157, 221),
                  strokeWidth: 2,
                ),
              );
            } else if (state is OnlineCoachingErrorState) {
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
            } else if (state is OnlineCoachingLoadedState) {
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
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<OnlineCoachingCubit>().loadCurrentSubscribers();
                },
                child: ListView.builder(
                  padding: EdgeInsets.only(),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: state.currentSubscribers.length,
                  itemBuilder: (context, index) {
                    final subscriber = state.currentSubscribers[index];

                    return OnlineSubscriberBox(subcriber: subscriber);
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

class OnlineSubscriberBox extends StatefulWidget {
  OnlineSubscriberBox({super.key, required this.subcriber});
  CurrentSubcriber subcriber;
  @override
  State<OnlineSubscriberBox> createState() => _OnlineSubscriberBoxState();
}

class _OnlineSubscriberBoxState extends State<OnlineSubscriberBox> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
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
                            "${widget.subcriber.firstNane} ${widget.subcriber.lastName}",
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
                            widget.subcriber.age.toString(),
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
                            widget.subcriber.email.toString(),
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
                                print("Copy email: ${widget.subcriber.email}");
                                Clipboard.setData(
                                  ClipboardData(text: widget.subcriber.email),
                                );
                              },
                              icon: Icon(Coolicons.copy),
                              iconSize: 20,
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                      Colors.white,
                                    ),
                                padding:
                                    WidgetStateProperty.all<EdgeInsetsGeometry>(
                                      const EdgeInsets.symmetric(
                                        vertical: 0,
                                        horizontal: 0,
                                      ),
                                    ),

                                shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder
                                >(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
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
                            launchGmail(widget.subcriber.email);
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
                                widget.subcriber.status == "active"
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
                                widget.subcriber.status == "active"
                                    ? Coolicons.check
                                    : Coolicons.close_big,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                widget.subcriber.status == "active"
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
                  ],
                ),
              )
              : Container(),
        ],
      ),
    );
  }
}
