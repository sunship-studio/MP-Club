import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/data/models/UserExercise.dart';
import 'package:mpc_mobile_app/presentation/widgets/column_builder.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ExercisesList extends StatelessWidget {
  const ExercisesList({
    super.key,
    required this.days,
    required this.selectedDayIndex,
    required this.exercises,
    this.onWeightChanged,
  });

  final List<String> days;
  final List<UserExercise> exercises;
  final int selectedDayIndex;
  final void Function(int exerciseIndex, int setIndex, int newWeight)?
  onWeightChanged;

  Future<void> _showWeightEditor(
    BuildContext context,
    int exerciseIndex,
  ) async {
    final sets = exercises[exerciseIndex].sets;
    if (sets == null || sets.isEmpty) {
      return;
    }

    final editedWeights = sets.map((set) => set.weight.toString()).toList();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          title: Text(
            '${exercises[exerciseIndex].name} - Weight',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextColor,
            ),
          ),
          content: SizedBox(
            width: 300.w,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(sets.length, (setIndex) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: TextFormField(
                      initialValue: editedWeights[setIndex],
                      onChanged: (value) {
                        editedWeights[setIndex] = value;
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Set ${setIndex + 1} (kg)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Future<void>.delayed(Duration.zero, () {
                  for (var setIndex = 0; setIndex < sets.length; setIndex++) {
                    final parsedWeight = int.tryParse(editedWeights[setIndex]);
                    if (parsedWeight != null && parsedWeight >= 0) {
                      onWeightChanged?.call(
                        exerciseIndex,
                        setIndex,
                        parsedWeight,
                      );
                    }
                  }
                });
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          days[selectedDayIndex],
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextColor,
          ),
        ),
        Gap(12.h),
        ColumnBuilder(
          itemBuilder: (context, i) {
            final repValues =
                exercises[i].sets != null && exercises[i].sets!.isNotEmpty
                    ? exercises[i].sets!.map((e) => e.reps).toSet().toList()
                    : <String>[];
            final repsDisplay =
                repValues.isEmpty
                    ? '0'
                    : repValues.length == 1
                    ? repValues.first
                    : repValues.join('/');
            final weightValues =
                exercises[i].sets != null && exercises[i].sets!.isNotEmpty
                    ? exercises[i].sets!
                        .map((e) => e.weight.toString())
                        .toList()
                    : <String>[];
            final weightsDisplay =
                weightValues.isEmpty ? '0' : weightValues.join('/');

            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: AppColors.lightScaffoldColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: ExerciseThumbnail(videoUrl: exercises[i].videoUrl),
                    ),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercises[i].name,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkTextColor,
                          ),
                        ),
                        Gap(4.h),
                        Row(
                          children: [
                            ExerciseInfoText(
                              value: "${exercises[i].sets?.length ?? 0}",
                              label: "SETS",
                            ),
                            InfoDivider(),
                            ExerciseInfoText(value: repsDisplay, label: "REPS"),
                            InfoDivider(),
                            ExerciseInfoText(
                              value:
                                  "${exercises[i].minutes}:${exercises[i].seconds! < 10 ? '0${exercises[i].seconds}' : exercises[i].seconds}",
                              label: "REST",
                            ),
                          ],
                        ),
                        Gap(8.h),
                        GestureDetector(
                          onTap: () => _showWeightEditor(context, i),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.lightScaffoldColor,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.fitness_center,
                                  size: 14.w,
                                  color: AppColors.darkTextColor,
                                ),
                                Gap(6.w),
                                ExerciseInfoText(
                                  value: weightsDisplay,
                                  label: "KG",
                                ),
                                Gap(4.w),
                                Icon(
                                  Icons.edit_outlined,
                                  size: 14.w,
                                  color: AppColors.darkTextColor.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          itemCount: exercises.length,
        ),
      ],
    );
  }
}

class ExerciseThumbnail extends StatefulWidget {
  const ExerciseThumbnail({super.key, this.videoUrl});

  final String? videoUrl;

  @override
  State<ExerciseThumbnail> createState() => _ExerciseThumbnailState();
}

class _ExerciseThumbnailState extends State<ExerciseThumbnail> {
  static final Map<String, Uint8List?> _thumbnailCache = {};
  Uint8List? _thumbnail;
  bool _loading = false;
  bool _requestedGeneratedThumbnail = false;

  String? _buildJpegUrl(String? videoUrl) {
    if (videoUrl == null || videoUrl.isEmpty) {
      return null;
    }

    final hasMp4 = RegExp(
      r'\.mp4(\?.*)?$',
      caseSensitive: false,
    ).hasMatch(videoUrl);
    if (!hasMp4) {
      return null;
    }

    return videoUrl.replaceFirst(
      RegExp(r'\.mp4(?=(\?.*)?$)', caseSensitive: false),
      '.jpeg',
    );
  }

  @override
  void initState() {
    super.initState();
    if (_buildJpegUrl(widget.videoUrl) == null) {
      _loadThumbnail();
    }
  }

  @override
  void didUpdateWidget(covariant ExerciseThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _thumbnail = null;
      _loading = false;
      _requestedGeneratedThumbnail = false;
      if (_buildJpegUrl(widget.videoUrl) == null) {
        _loadThumbnail();
      }
    }
  }

  Future<void> _loadThumbnail() async {
    final url = widget.videoUrl;
    if (url == null || url.isEmpty) {
      return;
    }

    if (_thumbnailCache.containsKey(url)) {
      setState(() {
        _thumbnail = _thumbnailCache[url];
      });
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final data = await VideoThumbnail.thumbnailData(
        video: url,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 200,
        quality: 70,
        timeMs: 1000,
      );

      _thumbnailCache[url] = data;
      if (mounted) {
        setState(() {
          _thumbnail = data;
        });
      }
    } catch (_) {
      _thumbnailCache[url] = null;
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final derivedJpegUrl = _buildJpegUrl(widget.videoUrl);

    if (derivedJpegUrl != null) {
      return Image.network(
        derivedJpegUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          if (!_requestedGeneratedThumbnail) {
            _requestedGeneratedThumbnail = true;
            _loadThumbnail();
          }

          if (_thumbnail != null) {
            return Image.memory(_thumbnail!, fit: BoxFit.cover);
          }

          if (_loading) {
            return Center(
              child: SizedBox(
                width: 14.w,
                height: 14.w,
                child: CircularProgressIndicator(strokeWidth: 1.6),
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.all(8.w),
            child: SvgPicture.asset("assets/images/exercise.svg"),
          );
        },
      );
    }

    if (_thumbnail != null) {
      return Image.memory(_thumbnail!, fit: BoxFit.cover);
    }

    if (_loading) {
      return Center(
        child: SizedBox(
          width: 14.w,
          height: 14.w,
          child: CircularProgressIndicator(strokeWidth: 1.6),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(8.w),
      child: SvgPicture.asset("assets/images/exercise.svg"),
    );
  }
}

class InfoDivider extends StatelessWidget {
  const InfoDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12.h,
      width: 1.w,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      color: AppColors.darkTextColor.withValues(alpha: 0.3),
    );
  }
}

class ExerciseInfoText extends StatelessWidget {
  const ExerciseInfoText({super.key, this.value = "15", this.label = "KG"});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextColor.withValues(alpha: 0.9),
          ),
        ),
        Gap(3.w),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextColor.withValues(alpha: 0.6),
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}
