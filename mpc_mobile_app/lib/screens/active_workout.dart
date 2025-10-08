import 'package:coolicons/coolicons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/widgets/circular_button.dart';
import 'package:video_player/video_player.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  bool _isInitialized = false;
  bool _isMuted = false;
  bool _showContainer = false;

  @override
  void initState() {
    super.initState();

    _initializeVideo();
    _toggleMute();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _setupAnimation() {
    // Animation controller for slide in/out
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200), // Slide duration
    );

    // Slide from right (1.0) to center (0.0)
    _slideAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0), // Start from right
      end: Offset(0.0, 0.0), // End at center
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start the sequence after a short delay
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _showContainer = true;
      });

      // Slide in
      _animationController.forward();

      // Wait 10 seconds then slide out
      Future.delayed(Duration(seconds: 10), () {
        _animationController.reverse().then((_) {
          setState(() {
            _showContainer = false;
          });
        });
      });
    });
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset('assets/videos/workout.mp4');
    await _controller.initialize();
   

    setState(() {
      _isInitialized = true;
    });

    await _controller.play();
    await _controller.setLooping(true);
    _setupAnimation();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  List<String> exercises = [
    "Cable Pull Downs",
    "Dumbbell Rows",
    "Bicep Curls",
    "Tricep Extensions",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: // Video player - full screen
          Stack(
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
          // Overlay content
          Column(
            children: [
              Container(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        padding: EdgeInsets.only(
                          right: horizontalPadding.w,
                          left: horizontalPadding.w,
                          top: topPadding(context),
                          bottom: 10.h,
                        ),
                        child: Icon(
                          CupertinoIcons.stop_circle,
                          size: 32.w,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(
                          left: horizontalPadding.w,
                          right: horizontalPadding.w,
                          bottom: 10.h,
                          top: topPadding(context),
                        ),
                        child: Text(
                          "Upper Body Strength",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                            letterSpacing: -0.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Container(width: horizontalPadding.w * 2 + 32.w, height: 0),
                  ],
                ),
              ),
              Gap(4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w),
                child: Row(
                  children: [
                    ...exercises.map(
                      (e) => Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                            left: horizontalPadding.w / 3.5,
                            right: horizontalPadding.w / 3.5,
                          ),
                          height: 4.h,
                          decoration: BoxDecoration(
                            color:
                                exercises.indexOf(e) == 0
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4.h),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: EdgeInsets.only(bottom: bottomPadding(context).h),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Container(
                          child: Column(
                            children: [
                              Text(
                                "0:34",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 44.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -1,
                                  height: 1,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              Gap(4.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Cable Pull Downs",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.4,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  Gap(8.w),
                                  ExerciseInfoBox(label: "REPS", value: "12"),
                                ],
                              ),
                              Gap(4.h),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ExerciseInfoBox(label: "SETS", value: "1/4"),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                    ),
                                    width: 1.w,
                                    height: 12.w,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  ExerciseInfoBox(
                                    label: "WEIGHT",
                                    value: "20kg",
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                    ),
                                    width: 1.w,
                                    height: 12.w,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  ExerciseInfoBox(label: "REST", value: "120s"),
                                ],
                              ),
                              Gap(16.h),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding.w,
                          ),
                          child: Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: CircularButton(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderColor: Colors.white.withValues(
                                    alpha: 0.2,
                                  ),
                                  label: "Back",
                                  dark: true,
                                  onTap: () async {
                                    if (_controller.value.isPlaying) {
                                      _controller.pause();
                                    } else {
                                      _controller.play();
                                    }
                                    setState(() {});
                                  },
                                ),
                              ),
                              Gap(12.w),
                              Flexible(
                                flex: 2,
                                child: CircularButton(
                                  color: Colors.white,
                                  icon: Icon(
                                    _controller.value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: AppColors.darkTextColor,
                                    size: 20.w,
                                  ),
                                  label: "Pause",
                                  textColor: AppColors.darkTextColor,
                                  dark: true,
                                  onTap: () async {
                                    if (_controller.value.isPlaying) {
                                      _controller.pause();
                                    } else {
                                      _controller.play();
                                    }
                                    setState(() {});
                                  },
                                ),
                              ),
                              Gap(12.w),
                              Flexible(
                                flex: 1,
                                child: CircularButton(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderColor: Colors.white.withValues(
                                    alpha: 0.2,
                                  ),
                                  label: "Next",
                                  dark: true,
                                  onTap: () async {},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_showContainer)
            Positioned(
              right: 0,

              bottom: bottomPadding(context).h + MediaQuery.of(context).size.height * 0.2,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  height: 164.h,
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Container(
                      margin: EdgeInsets.all(16),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                      
                        image: DecorationImage(
                          opacity: 0.8,
                          fit: BoxFit.cover,
                          image: AssetImage('assets/images/thumbnail.png'),
                        ),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.play_circle,
                            size: 40,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Full Tutorial',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
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

class ExerciseInfoBox extends StatelessWidget {
  ExerciseInfoBox({super.key, required this.label, required this.value});

  String label;
  String value;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "$value ",
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            fontFamily: 'Inter',
          ),
        ),
        Gap(4.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4.h),
          ),
          child: Text(
            "$label",
            style: TextStyle(
              color: Colors.white,

              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }
}
