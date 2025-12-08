import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/cubits/auth.dart';
import 'package:mpc_mobile_app/data/models/TrainingDay.dart';
import 'package:mpc_mobile_app/presentation/widgets/circular_button.dart';
import 'package:mpc_mobile_app/routes/main.dart';
import 'package:mpc_mobile_app/services/snack_bar.dart';
import 'package:video_player/video_player.dart';

String _formatTime(int seconds) {
  final minutes = (seconds % 3600) ~/ 60;
  final secs = seconds % 60;

  return '${minutes.toString().padLeft(1, '0')}:'
      '${secs.toString().padLeft(2, '0')}';
}

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key, required this.trainingDay});
  final TrainingDay trainingDay;

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  int _seconds = 0;
  int _restSeconds = 0;
  int currentExercise = 0;
  int currentSet = 1;

  Timer? _timer;
  Timer? restTimer;
  bool _isResting = false;
  bool _isInitialized = false;
  bool _isMuted = false;
  bool _showTutorial = false;
  bool _showTip = false;

  @override
  void initState() {
    super.initState();

    _initializeVideo();
    startTimer();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navBarKey.currentState?.turnOffNavBar();
    });
  }

  void startRestPeriod(int seconds) {
    // Cancel any existing timers to prevent overlaps
    _timer?.cancel();
    restTimer?.cancel();

    _controller.pause();
    setState(() {
      _isResting = true;
      _seconds = 0;
      _restSeconds = seconds;
    });
    restTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_restSeconds <= 0) {
        restTimer?.cancel();
        _controller.play();
        setState(() {
          _isResting = false;
          currentSet++;
          _seconds = 0;
        });
        startTimer();
      } else {
        setState(() {
          _restSeconds--;
        });
      }
    });
  }

  Future<void> _setupAnimation() async {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (videoUrl != null) {
      await _showTutorialAnimation();
    }

    await _showTipAnimation();
  }

  Future<void> _showTutorialAnimation() async {
    await Future.delayed(Duration(milliseconds: 2000));
    setState(() {
      _showTutorial = true;
    });
    await _animationController.forward();
    await Future.delayed(Duration(seconds: 6));
    await _animationController.reverse();
    setState(() {
      _showTutorial = false;
    });
  }

  Future<void> _showTipAnimation() async {
    await Future.delayed(Duration(seconds: 5));
    setState(() {
      _showTip = true;
    });
    await _animationController.forward();
    await Future.delayed(Duration(seconds: 4));
    await _animationController.reverse();
    setState(() {
      _showTip = false;
    });
  }

  void startTimer() {
    // Cancel existing timer if any to prevent double counting
    _timer?.cancel();

    // Only start timer if not already active and not resting
    if (_timer?.isActive == true || _isResting) {
      return;
    }

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  String? videoUrl;

  Future<void> _initializeVideo() async {
    videoUrl = widget.trainingDay.exercises[currentExercise].videoUrl;

    if (videoUrl == null || videoUrl!.isEmpty) {
      // Use local placeholder video
      _controller = VideoPlayerController.asset('assets/videos/workout.mp4');
    } else {
      // Use network video if URL is provided
      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl!));
    }

    await _controller.initialize();

    setState(() {
      _isInitialized = true;
    });

    await _controller.play();
    await _controller.setLooping(true);
    _toggleMute();
    _setupAnimation();
  }

  Future<void> _switchVideo(int exerciseIndex) async {
    await _controller.pause();
    await _controller.dispose();

    videoUrl = widget.trainingDay.exercises[exerciseIndex].videoUrl;

    if (videoUrl == null || videoUrl!.isEmpty) {
      return;
    }

    _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl!));
    await _controller.initialize();
    await _controller.setLooping(true);
    _controller.setVolume(_isMuted ? 0.0 : 1.0);
    if (!_isResting) {
      await _controller.play();
    }

    // Run tutorial animation in background without blocking
    _showTutorialAnimation();
    setState(() {});
  }

  void _toggleMute() {
    _isMuted = !_isMuted;
    _controller.setVolume(_isMuted ? 0.0 : 1.0);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navBarKey.currentState?.turnOnNavBar();
    });
    _timer?.cancel();
    restTimer?.cancel();
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkScaffoldColor,
      body: // Video player - full screen
          BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (!_isInitialized) {
            return Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          state as Authenticated;
          return Stack(
            children: [
              videoUrl == null || videoUrl!.isEmpty
                  ? Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding.w,
                      ),
                      child: Text(
                        "Unfortunately, there is no video available for this exercise. Soon we will add more videos to our library!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                  : SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  ),

              Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showStopWorkoutDialog(context, () {
                            context.pop();
                            Navigator.of(context).pop();
                          });
                        },
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
                            state.user.trainingPlan.name,
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
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _toggleMute();
                          });
                        },
                        behavior: HitTestBehavior.translucent,
                        child: Container(
                          padding: EdgeInsets.only(
                            left: horizontalPadding.w,
                            right: horizontalPadding.w,
                            top: topPadding(context),
                            bottom: 10.h,
                          ),
                          child: Icon(
                            _isMuted
                                ? CupertinoIcons.volume_mute
                                : CupertinoIcons.volume_up,
                            size: 32.w,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(4.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding.w,
                    ),
                    child: Row(
                      children: [
                        ...widget.trainingDay.exercises.map(
                          (e) => Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                _timer?.cancel();
                                final newExerciseIndex = widget
                                    .trainingDay
                                    .exercises
                                    .indexOf(e);
                                if (newExerciseIndex != currentExercise) {
                                  setState(() {
                                    currentExercise = newExerciseIndex;
                                    currentSet = 1;
                                    _seconds = 0;
                                  });
                                  await _switchVideo(newExerciseIndex);
                                  startTimer();
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                  left: horizontalPadding.w / 3.5,
                                  right: horizontalPadding.w / 3.5,
                                ),
                                height: 12.h,
                                decoration: BoxDecoration(
                                  color:
                                      widget.trainingDay.exercises.indexOf(e) ==
                                              currentExercise
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(6.h),
                                ),
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
                        margin: EdgeInsets.only(
                          bottom: bottomPadding(context).h,
                        ),

                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isResting
                                  ? _formatTime(_restSeconds)
                                  : _formatTime(_seconds),
                              style: TextStyle(
                                color: _isResting ? Colors.amber : Colors.white,
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
                                  widget
                                      .trainingDay
                                      .exercises[currentExercise]
                                      .name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.4,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                Gap(8.w),
                                ExerciseInfoBox(
                                  fontSize: 12,
                                  label: "REPS",
                                  value:
                                      widget
                                          .trainingDay
                                          .exercises[currentExercise]
                                          .sets
                                          ?.first
                                          .reps
                                          .toString() ??
                                      "0",
                                ),
                              ],
                            ),
                            Gap(4.h),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ExerciseInfoBox(
                                  label: "SETS",
                                  value:
                                      "$currentSet/${widget.trainingDay.exercises[currentExercise].sets?.length}",
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 8.w),
                                  width: 1.w,
                                  height: 12.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                                ExerciseInfoBox(
                                  label: "WEIGHT",
                                  value:
                                      "${widget.trainingDay.exercises[currentExercise].sets![currentSet - 1].weight}kg",
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 8.w),
                                  width: 1.w,
                                  height: 12.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                                ExerciseInfoBox(
                                  label: "REST",
                                  value:
                                      "${widget.trainingDay.exercises[currentExercise].minutes}min ${widget.trainingDay.exercises[currentExercise].seconds! < 10 ? "0${widget.trainingDay.exercises[currentExercise].seconds}" : widget.trainingDay.exercises[currentExercise].seconds}s",
                                ),
                              ],
                            ),
                            Gap(16.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding.w,
                              ),
                              child: Row(
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: CircularButton(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderColor: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      label: "Back",
                                      dark: true,
                                      onTap: () async {
                                        if (currentSet > 1 && !_isResting) {
                                          setState(() {
                                            currentSet--;
                                            _seconds = 0;
                                          });
                                          startTimer();
                                        } else if (_isResting &&
                                            currentSet > 1) {
                                          _timer?.cancel();
                                          restTimer?.cancel();
                                          await _controller.play();

                                          setState(() {
                                            _isResting = false;
                                            restTimer?.cancel();
                                            _controller.play();
                                            currentSet--;
                                          });
                                          startTimer();
                                        } else if (currentExercise > 0 &&
                                            !_isResting) {
                                          setState(() {
                                            currentExercise--;
                                            currentSet =
                                                widget
                                                    .trainingDay
                                                    .exercises[currentExercise]
                                                    .sets!
                                                    .length;
                                            _seconds = 0;
                                          });
                                          await _switchVideo(currentExercise);
                                          startTimer();
                                        } else if (_isResting &&
                                            currentExercise > 0) {
                                          _timer?.cancel();
                                          restTimer?.cancel();
                                          setState(() {
                                            _isResting = false;
                                            currentExercise--;
                                            _seconds = 0;

                                            currentSet =
                                                widget
                                                    .trainingDay
                                                    .exercises[currentExercise]
                                                    .sets!
                                                    .length;
                                          });
                                          await _switchVideo(currentExercise);
                                          await _controller.play();
                                          startTimer();
                                        }
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
                                      label:
                                          _isResting
                                              ? "Skip Rest"
                                              : _controller.value.isPlaying
                                              ? "Pause"
                                              : "Play",
                                      textColor: AppColors.darkTextColor,
                                      dark: true,
                                      onTap: () async {
                                        if (_isResting) {
                                          setState(() {
                                            _isResting = false;
                                            restTimer?.cancel();
                                            _controller.play();
                                            currentSet++;
                                            _seconds = 0;
                                          });
                                          startTimer();
                                          return;
                                        } else if (_controller
                                            .value
                                            .isPlaying) {
                                          _timer?.cancel();
                                          await _controller.pause();
                                        } else if (!_controller
                                            .value
                                            .isPlaying) {
                                          startTimer();
                                          await _controller.play();
                                        }
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                  Gap(12.w),
                                  Flexible(
                                    flex: 1,
                                    child: CircularButton(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderColor: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      label: "Next",
                                      dark: true,
                                      onTap: () async {
                                        if (_isResting) {
                                          setState(() {
                                            _isResting = false;
                                            restTimer?.cancel();
                                            _controller.play();
                                            currentSet++;
                                            _seconds = 0;
                                            startTimer();
                                          });
                                        } else if (widget
                                                .trainingDay
                                                .exercises[currentExercise]
                                                .sets!
                                                .length >
                                            currentSet) {
                                          // Move to next set
                                          ScaffoldMessenger.of(
                                            context,
                                          ).clearSnackBars();
                                          setState(() {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                duration: Duration(
                                                  milliseconds: 1500,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        12.0,
                                                      ),
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,

                                                margin: EdgeInsets.only(
                                                  left: horizontalPadding.w,
                                                  right: horizontalPadding.w,
                                                  bottom:
                                                      bottomPadding(context).h +
                                                      140.h,
                                                ),
                                                backgroundColor: Colors.white,

                                                content: Text(
                                                  'Starting rest period',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            );
                                            _timer?.cancel();
                                            startRestPeriod(
                                              widget
                                                      .trainingDay
                                                      .exercises[currentExercise]
                                                      .seconds! +
                                                  widget
                                                          .trainingDay
                                                          .exercises[currentExercise]
                                                          .minutes! *
                                                      60,
                                            );
                                          });
                                        } else if (widget
                                                .trainingDay
                                                .exercises
                                                .length >
                                            currentExercise + 1) {
                                          setState(() {
                                            currentExercise++;
                                            _seconds = 0;
                                            currentSet = 1;
                                          });
                                          await _switchVideo(currentExercise);
                                        } else {
                                          _timer?.cancel();
                                          await _controller.pause();
                                          context.pop();
                                          navBarKey.currentState!
                                              .turnOnNavBar();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).clearSnackBars();
                                          SnackBarService.show(
                                            context: context,
                                            message:
                                                "Congrats! Workout has finished successfully!",
                                            isNavBar: true,
                                          );
                                        }
                                      },
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
              if (_showTutorial)
                TutorialSlide(
                  timer: _timer!,
                  controller: _controller,
                  slideAnimation: _slideAnimation,
                  videoUrl: videoUrl,
                ),
              if (_showTip)
                TipBox(
                  slideAnimation: _slideAnimation,
                  exercisesLength: widget.trainingDay.exercises.length,
                ),
            ],
          );
        },
      ),
    );
  }
}

class TipBox extends StatelessWidget {
  const TipBox({
    super.key,
    required Animation<Offset> slideAnimation,
    required this.exercisesLength,
  }) : _slideAnimation = slideAnimation;

  final Animation<Offset> _slideAnimation;
  final int exercisesLength;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: topPadding(context).h + 60.h),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w),
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var i = 0; i < exercisesLength; i++)
                    i != 0
                        ? Icon(
                          Icons.arrow_upward_rounded,
                          size: 28.w,
                          color: Colors.white.withValues(alpha: 0.8),
                        )
                        : SizedBox(width: 28.w, height: 28.w),
                ],
              ),
            ),
            Gap(4.h),
            Container(
              child: Text(
                "Here you can switch/skip exercises",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TutorialSlide extends StatefulWidget {
  const TutorialSlide({
    super.key,
    required Animation<Offset> slideAnimation,
    required this.controller,
    required this.timer,
    this.videoUrl,
  }) : _slideAnimation = slideAnimation;

  final Animation<Offset> _slideAnimation;
  final Timer timer;
  final String? videoUrl;
  final VideoPlayerController controller;

  @override
  State<TutorialSlide> createState() => _TutorialSlideState();
}

class _TutorialSlideState extends State<TutorialSlide> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,

      bottom:
          bottomPadding(context).h + MediaQuery.of(context).size.height * 0.2,
      child: SlideTransition(
        position: widget._slideAnimation,
        child: GestureDetector(
          onTapDown: (_) {
            setState(() {
              _isPressed = true;
            });
          },
          onTapUp: (_) {
            setState(() {
              _isPressed = false;
            });
            if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
              context.push('/tutorial/', extra: widget.videoUrl);
              widget.controller.pause();
              widget.timer.cancel();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Tutorial video is not available for this exercise.',
                  ),
                ),
              );
            }
          },
          child: SizedBox(
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
                    image: NetworkImage(
                      widget.videoUrl != null && widget.videoUrl!.isNotEmpty
                          ? widget.videoUrl!.replaceAll('mp4', 'jpeg')
                          : 'https://www.example.com/placeholder_image.jpg',
                    ),
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
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
    );
  }
}

class ExerciseInfoBox extends StatelessWidget {
  const ExerciseInfoBox({
    super.key,
    required this.label,
    required this.value,
    this.fontSize = 11,
  });

  final String label;
  final String value;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "$value ",
          style: TextStyle(
            color: Colors.white,
            fontSize: (fontSize + 1).sp,
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
            label,
            style: TextStyle(
              color: Colors.white,

              fontSize: fontSize.sp,
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

void showStopWorkoutDialog(BuildContext context, Function onStop) {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text('Stop Workout'),
        content: Text(
          'Do you really want to stop the workout? All progress will be lost.',
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(
              'Yes, Stop',
              style: TextStyle(
                color: AppColors.blueColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: () {
              onStop();
            },
          ),
          CupertinoDialogAction(
            child: Text(
              'No, Continue',
              style: TextStyle(
                color: AppColors.blueColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
