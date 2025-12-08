import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/data/models/Exercise.dart';
import 'package:mpc_mobile_app/presentation/widgets/back_button.dart';
import 'package:video_player/video_player.dart';

class TutorialScreen extends StatefulWidget {
  final Exercise exercise;
  const TutorialScreen({super.key, required this.exercise});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  @override
  void initState() {
    super.initState();
    // Allow all orientations for this screen
    _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.exercise.videoUrl),
      )
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  VideoPlayerController? _controller;
  bool isFullscreen = false;

  void toggleFullscreen() {
    setState(() {
      isFullscreen = !isFullscreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          body:
              !isFullscreen
                  ? TutorialDetailScreen(
                    exercise: widget.exercise,
                    controller: _controller,
                    toggleFullscreen: toggleFullscreen,
                  )
                  : FullscreenPlayerScreen(
                    exercise: widget.exercise,
                    controller: _controller!,
                    toggleFullscreen: toggleFullscreen,
                  ),
        );
      },
    );
  }
}

class TutorialDetailScreen extends StatefulWidget {
  const TutorialDetailScreen({
    super.key,
    required this.exercise,
    required this.controller,
    required this.toggleFullscreen,
  });

  final Exercise exercise;
  final VideoPlayerController? controller;
  final VoidCallback? toggleFullscreen;

  @override
  State<TutorialDetailScreen> createState() => _TutorialDetailScreenState();
}

class _TutorialDetailScreenState extends State<TutorialDetailScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: topPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: AlignmentGeometry.bottomLeft,
                  child: MpcBackButton(color: Colors.black),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "Tutorial Details",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Expanded(child: SizedBox(width: 48)), // Placeholder for alignment
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(2.r),
            ),
            height: 212.h,
            width: double.infinity,
            child: Stack(
              children: [
                Center(
                  child:
                      widget.controller!.value.isInitialized
                          ? AspectRatio(
                            aspectRatio: widget.controller!.value.aspectRatio,
                            child: VideoPlayer(widget.controller!),
                          )
                          : SizedBox.shrink(),
                ),
                // Loading indicator when buffering
                if (widget.controller!.value.isBuffering)
                  Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3.0,
                    ),
                  ),
                Align(
                  alignment: AlignmentGeometry.bottomCenter,
                  child: Row(
                    children: [
                      PlayButton(
                        controller: widget.controller!,
                        onTap: () {
                          if (widget.controller!.value.isPlaying) {
                            setState(() {
                              widget.controller!.pause();
                            });
                          } else {
                            setState(() {
                              widget.controller!.play();
                            });
                          }
                        },
                      ),

                      DurationCounter(controller: widget.controller!),
                      Spacer(),
                      FullscreenButton(
                        toggleFullscreen: () {
                          widget.toggleFullscreen?.call();
                        },
                      ),
                    ],
                  ),
                ),
                DurationProgressBar(controller: widget.controller!),
                widget.controller!.value.isPlaying
                    ? SizedBox.shrink()
                    : BigPlayButton(
                      onTap: () {
                        setState(() {
                          widget.controller!.play();
                        });
                      },
                    ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding.w,
              vertical: 16.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.exercise.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8.h),
                Text(
                  Constants.formatDuration(
                    Duration(seconds: widget.exercise.videoLengthSeconds),
                  ),
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
                SizedBox(height: 24.h),
                // Text(
                //   "DESCRIPTION",
                //   style: TextStyle(
                //     fontSize: 12.sp,
                //     color: AppColors.darkTextColor,
                //     fontWeight: FontWeight.w700,
                //   ),
                // ),
                // SizedBox(height: 8.h),
                // Text(
                //   "This is a detailed description of the tutorial. It provides insights and information about what will be covered in the tutorial, including key points and objectives.",
                //   style: TextStyle(
                //     fontSize: 14.sp,
                //     color: AppColors.greyTextColor,
                //     fontWeight: FontWeight.w400,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DurationCounter extends StatefulWidget {
  const DurationCounter({super.key, required this.controller});
  final VideoPlayerController controller;

  @override
  State<DurationCounter> createState() => _DurationCounterState();
}

class _DurationCounterState extends State<DurationCounter> {
  @override
  void initState() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      } else {
        timer.cancel();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "${widget.controller.value.position.inMinutes}:${(widget.controller.value.position.inSeconds % 60).toString().padLeft(2, '0')}/${widget.controller.value.duration.inMinutes}:${(widget.controller.value.duration.inSeconds % 60).toString().padLeft(2, '0')}            ",
      style: TextStyle(
        color: Colors.white,
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class BigPlayButton extends StatefulWidget {
  const BigPlayButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  State<BigPlayButton> createState() => _BigPlayButtonState();
}

class _BigPlayButtonState extends State<BigPlayButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:
          (details) => {
            setState(() {
              _isPressed = true;
            }),
          },
      onTapUp:
          (details) => {
            setState(() {
              _isPressed = false;
            }),
          },
      onTapCancel:
          () => {
            setState(() {
              _isPressed = false;
            }),
          },
      onTap: () => {widget.onTap()},
      child: Center(
        child: Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color.fromARGB(255, 85, 85, 85).withAlpha(190),
                Colors.white.withAlpha(255),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            size: 24.h,
            color: Colors.white.withAlpha(255),
          ),
        ),
      ),
    );
  }
}

class FullscreenButton extends StatefulWidget {
  const FullscreenButton({super.key, required this.toggleFullscreen});
  final VoidCallback? toggleFullscreen;

  @override
  State<FullscreenButton> createState() => _FullscreenButtonState();
}

class _FullscreenButtonState extends State<FullscreenButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      onTap: () => {widget.toggleFullscreen?.call()},

      child: AnimatedOpacity(
        duration: Duration(milliseconds: 100),
        opacity: _isPressed ? 0.8 : 1.0,
        child: AnimatedScale(
          duration: Duration(milliseconds: 100),

          scale: _isPressed ? 0.925 : 1.0,

          child: Padding(
            padding: EdgeInsets.only(
              right: horizontalPadding.w - 12,
              bottom: 12.h,
              top: 8.h,
              left: 8.w,
            ),
            child: Icon(
              Icons.fullscreen_rounded,
              color: Colors.white,
              size: 28.w,
            ),
          ),
        ),
      ),
    );
  }
}

class PlayButton extends StatefulWidget {
  PlayButton({super.key, required this.onTap, required this.controller});
  Function onTap;
  VideoPlayerController controller;
  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },

      onTap: () => {widget.onTap()},
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 100),
        opacity: _isPressed ? 0.8 : 1.0,
        child: AnimatedScale(
          duration: Duration(milliseconds: 100),

          scale: _isPressed ? 0.925 : 1.0,

          child: Padding(
            padding: EdgeInsets.only(
              left: horizontalPadding.w - 12,
              bottom: 8.h,
              top: 8.h,
              right: 8.w,
            ),
            child: Icon(
              widget.controller.value.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 32.w,
            ),
          ),
        ),
      ),
    );
  }
}

class FullscreenPlayerScreen extends StatefulWidget {
  const FullscreenPlayerScreen({
    super.key,
    required this.controller,
    required this.toggleFullscreen,
    required this.exercise,
  });
  final VideoPlayerController controller;
  final Function toggleFullscreen;
  final Exercise exercise;

  @override
  State<FullscreenPlayerScreen> createState() => _FullscreenPlayerScreenState();
}

class _FullscreenPlayerScreenState extends State<FullscreenPlayerScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(color: AppColors.darkScaffoldColor),
          padding: EdgeInsets.only(top: topPadding(context)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MpcBackButton(color: Colors.white),
                  Text(
                    widget.exercise.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  MpcBackButton(color: Colors.transparent, onTap: () => {}),
                ],
              ),
              Expanded(
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: AspectRatio(
                        aspectRatio: widget.controller.value.aspectRatio,
                        child: VideoPlayer(widget.controller),
                      ),
                    ),
                    // Loading indicator when buffering
                    if (widget.controller.value.isBuffering)
                      Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3.0,
                        ),
                      ),
                    Container(
                      margin: EdgeInsets.only(bottom: bottomPadding(context)),
                      child: Align(
                        alignment: AlignmentGeometry.bottomCenter,
                        child: Row(
                          children: [
                            PlayButton(
                              controller: widget.controller,
                              onTap: () {
                                if (widget.controller.value.isPlaying) {
                                  setState(() {
                                    widget.controller.pause();
                                  });
                                } else {
                                  setState(() {
                                    widget.controller.play();
                                  });
                                }
                              },
                            ),

                            DurationCounter(controller: widget.controller),
                            Spacer(),
                            FullscreenButton(
                              toggleFullscreen: () {
                                widget.toggleFullscreen.call();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        bottom: bottomPadding(context) - 16,
                      ),

                      child: DurationProgressBar(
                        controller: widget.controller,
                        fullscreen: true,
                      ),
                    ),
                    !widget.controller.value.isPlaying
                        ? Center(
                          child: BigPlayButton(
                            onTap: () {
                              setState(() {
                                widget.controller.play();
                              });
                            },
                          ),
                        )
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DurationProgressBar extends StatefulWidget {
  DurationProgressBar({
    super.key,
    required this.controller,
    this.fullscreen = false,
  });
  final VideoPlayerController controller;
  bool fullscreen;

  @override
  State<DurationProgressBar> createState() => _DurationProgressBarState();
}

class _DurationProgressBarState extends State<DurationProgressBar> {
  bool _isDragging = false;
  double? _dragPosition;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onTapDown: (TapDownDetails details) {
          final box = context.findRenderObject() as RenderBox;
          final localPosition = details.localPosition;
          final width = box.size.width;
          final tapPercentage = localPosition.dx / width;

          final duration = widget.controller.value.duration;
          final newPosition = duration * tapPercentage;

          if (newPosition >= Duration.zero && newPosition <= duration) {
            widget.controller.seekTo(newPosition);
          }
          setState(() {});
        },
        onHorizontalDragStart: (details) {
          setState(() {
            _isDragging = true;
          });
        },
        onHorizontalDragUpdate: (details) {
          final box = context.findRenderObject() as RenderBox;
          final localPosition = box.globalToLocal(details.globalPosition);
          final width = box.size.width;
          final dragPercentage = (localPosition.dx / width).clamp(0.0, 1.0);

          setState(() {
            _dragPosition = dragPercentage;
          });
        },
        onHorizontalDragEnd: (details) {
          if (_dragPosition != null) {
            final duration = widget.controller.value.duration;
            final newPosition = duration * _dragPosition!;

            if (newPosition >= Duration.zero && newPosition <= duration) {
              widget.controller.seekTo(newPosition);
            }
          }

          setState(() {
            _isDragging = false;
            _dragPosition = null;
          });
        },
        onHorizontalDragCancel: () {
          setState(() {
            _isDragging = false;
            _dragPosition = null;
          });
        },
        child: SizedBox(
          height: widget.fullscreen ? 16.h : 5.h,
          child: LinearProgressIndicator(
            value:
                widget.controller.value.duration.inSeconds == 0
                    ? 0
                    : _isDragging && _dragPosition != null
                    ? _dragPosition
                    : widget.controller.value.position.inSeconds /
                        widget.controller.value.duration.inSeconds,
            backgroundColor: Colors.black.withValues(alpha: 0.01),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.redColor),
          ),
        ),
      ),
    );
  }
}
