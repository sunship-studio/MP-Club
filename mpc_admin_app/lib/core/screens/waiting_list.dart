import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpc_admin_app/app/bloc/waiting_list/cubit.dart';
import 'package:mpc_admin_app/app/bloc/waiting_list/state.dart';
import 'package:mpc_admin_app/app/models/WaitingListEntry.dart';
import 'package:url_launcher/url_launcher.dart';

class WaitingList extends StatelessWidget {
  const WaitingList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WaitingListCubit>(
      create: (context) => WaitingListCubit()..loadWaitingList(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: BlocBuilder<WaitingListCubit, WaitingListState>(
          builder: (context, state) {
            if (state is WaitingListLoadingState) {
              return Center(
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 19, 157, 221),
                  strokeWidth: 2,
                ),
              );
            } else if (state is WaitinglistErrorState) {
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
            } else if (state is WaitinglistLoadedState) {
              if (state.waitingList.isEmpty) {
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
                  context.read<WaitingListCubit>().loadWaitingList();
                },
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.waitingList.any(
                        (entry) => entry.approvalStatus == "pending",
                      ))
                        Text(
                          "Pending:",
                          style: TextStyle(
                            fontSize: 26,
                            fontFamily: 'SF-Pro',
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      if (state.waitingList.any(
                        (entry) => entry.approvalStatus == "pending",
                      ))
                        const SizedBox(height: 10),
                      ListView.builder(
                        padding: EdgeInsets.only(),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: state.waitingList.length,
                        itemBuilder: (context, index) {
                          final entry = state.waitingList[index];
                          if (entry.approvalStatus == "pending") {
                            print(entry);
                            return WaitingListEntryBox(entry: entry);
                          } else {
                            return Container();
                          }
                        },
                      ),
                      if (state.waitingList.any(
                        (entry) => entry.approvalStatus == "pending",
                      ))
                        const SizedBox(height: 10),
                      state.waitingList.any(
                            (entry) => entry.approvalStatus == "approved",
                          )
                          ? Text(
                            "Accepted:",
                            style: TextStyle(
                              fontSize: 26,
                              fontFamily: 'SF-Pro',
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                          : Container(),
                      const SizedBox(height: 10),
                      ListView.builder(
                        padding: EdgeInsets.only(),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: state.waitingList.length,
                        itemBuilder: (context, index) {
                          final entry = state.waitingList[index];
                          if (entry.approvalStatus == "approved") {
                            return WaitingListEntryBox(entry: entry);
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ],
                  ),
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

class WaitingListEntryBox extends StatefulWidget {
  WaitingListEntryBox({super.key, required this.entry});
  WaitingListEntry entry;
  @override
  State<WaitingListEntryBox> createState() => _WaitingListEntryBoxState();
}

class _WaitingListEntryBoxState extends State<WaitingListEntryBox> {
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
                            "${widget.entry.firstName} ${widget.entry.lastName}",
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
                            widget.entry.age.toString(),
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
                            widget.entry.email,
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
                                print("Copy email: ${widget.entry.email}");
                                Clipboard.setData(
                                  ClipboardData(text: widget.entry.email),
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
          isExpanded
              ? Container(
                margin: EdgeInsets.only(top: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        launchGmail(widget.entry.email);
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
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Availability:",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'SF-Pro',
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          ListView.builder(
                            padding: EdgeInsets.only(),
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount:
                                widget.entry.weeklyAvailability.days.length,
                            itemBuilder: (context, index) {
                              return AvailabilityDay(
                                dayAvailability:
                                    widget.entry.weeklyAvailability.days[index],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    if (widget.entry.approvalStatus == "pending")
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        child: Row(
                          children: [
                            FilledButton(
                              onPressed: () {
                                context.read<WaitingListCubit>().acceptEntry(
                                  widget.entry.id,
                                );
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                      Color.fromRGBO(54, 169, 222, 1),
                                    ),
                                padding: MaterialStateProperty.all<
                                  EdgeInsetsGeometry
                                >(
                                  const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 25,
                                  ),
                                ),
                                shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder
                                >(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                              child: Text(
                                "Accept",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'SF-Pro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            FilledButton(
                              onPressed: () {
                                context.read<WaitingListCubit>().rejectEntry(
                                  widget.entry.id,
                                );
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(
                                  const Color.fromARGB(255, 172, 77, 77)!,
                                ),
                                padding: MaterialStateProperty.all<
                                  EdgeInsetsGeometry
                                >(
                                  const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 28,
                                  ),
                                ),
                                shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder
                                >(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                              child: Text(
                                "Reject",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'SF-Pro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
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

class AvailabilityDay extends StatelessWidget {
  const AvailabilityDay({super.key, required this.dayAvailability});

  final DayAvailability dayAvailability;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: Color.fromRGBO(227, 227, 227, 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              dayAvailability.day,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'SF-Pro',
                color: const Color.fromARGB(255, 24, 147, 204),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  dayAvailability.allDay
                      ? "All day"
                      : "${dayAvailability.startTime} - ${dayAvailability.endTime}",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'SF-Pro',
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
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
