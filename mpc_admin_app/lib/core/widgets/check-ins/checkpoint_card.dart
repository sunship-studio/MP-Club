import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_admin_app/app/models/checkin.dart';

class CheckpointCard extends StatefulWidget {
  CheckpointCard({super.key, required this.onTap, required this.checkIn});
  Function? onTap;
  CheckIn checkIn;

  @override
  State<CheckpointCard> createState() => _MyCheckpointCardState();
}

class _MyCheckpointCardState extends State<CheckpointCard> {
  List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => setState(() {
            _isPressed = !_isPressed;
            if (widget.onTap != null) {
              widget.onTap!();
            }
          }),
      onTapDown:
          (details) => setState(() {
            _isPressed = true;
          }),
      onTapUp:
          (details) => setState(() {
            _isPressed = false;
          }),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(10.r),
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16.w),

        child: Row(
          children: [
            if (widget.checkIn.allPhotos.isNotEmpty)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      widget.checkIn.allPhotos.first,
                      width: 50.w,
                      height: 50.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (widget.checkIn.allPhotos.length > 1)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${widget.checkIn.allPhotos.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            if (widget.checkIn.allPhotos.isNotEmpty) Gap(10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${months[widget.checkIn.date.month - 1]} ${widget.checkIn.date.day}",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                  Gap(4.h),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      widget.checkIn.wellbeing != null && widget.checkIn.wellbeing!.isNotEmpty
                          ? widget.checkIn.wellbeing!
                          : (widget.checkIn.note == null ||
                              widget.checkIn.note!.isEmpty
                          ? "No notes added."
                          : "${widget.checkIn.note}"),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Inter',
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                      maxLines: 3,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.checkIn.weight.toStringAsFixed(0),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                    letterSpacing: -1.8,
                    height: 1,
                  ),
                ),
                Gap(4),
                Text(
                  "kg",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                    letterSpacing: -0.6,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
