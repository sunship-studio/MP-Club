import 'package:flutter/material.dart';
import 'package:mpc_admin_app/app/models/Exercise.dart';

class SuggestedExerciseBox extends StatelessWidget {
  SuggestedExerciseBox({
    super.key,
    required this.exercise,
    required this.selectedDayIndex,
    required this.searchController,
    required this.onTap,
  });
  final Exercise exercise;
  final VoidCallback onTap;
  TextEditingController searchController;
  final int selectedDayIndex;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'SF-Pro',
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6),
                ],
              ),
            ),

            AddButton(onTap: onTap),
          ],
        ),
      ),
    );
  }
}

class AddButton extends StatefulWidget {
  AddButton({super.key, required this.onTap});
  Function onTap;
  @override
  State<AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<AddButton> {
  bool _isPRessed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPRessed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPRessed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPRessed = false;
        });
      },
      onTap: () {
        widget.onTap();
      },
      child: AnimatedSize(
        duration: Duration(milliseconds: 100),

        child: Container(
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8),
              topLeft: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              Text(
                "Add exercise",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'SF-Pro',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 6),
              Icon(Icons.add, size: 20, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
