import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/cubits/tutorials.dart';
import 'package:mpc_mobile_app/presentation/widgets/column_builder.dart';
import 'package:mpc_mobile_app/presentation/widgets/tutorials_for_you.dart';

class TutorialsScreens extends StatefulWidget {
  const TutorialsScreens({super.key});

  @override
  State<TutorialsScreens> createState() => _TutorialsScreensState();
}

class _TutorialsScreensState extends State<TutorialsScreens> {
  bool _isSearchFocused = false;
  bool _isTyping = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TutorialCubit, TutorialState>(
        bloc: BlocProvider.of<TutorialCubit>(context),
        builder:
            (context, state) => Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                  ),
                  decoration: BoxDecoration(color: AppColors.darkScaffoldColor),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Gap(horizontalPadding.w),
                          _isSearchFocused
                              ? GestureDetector(
                                onTap: () {
                                  _searchFocusNode.unfocus();
                                },
                                child: Container(
                                  child: Icon(
                                    size: 28.w,
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                              : SizedBox(width: 28.w),

                          Expanded(
                            child: Center(
                              child: Text(
                                _isSearchFocused
                                    ? "Search Tutorials"
                                    : "Tutorials Screen",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 64.w),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(color: AppColors.darkScaffoldColor),
                  child: Container(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          child: TextField(
                            onChanged: (value) {
                              if (value.isEmpty) {
                                context.read<TutorialCubit>().clearSearch();
                              }
                              setState(() {
                                _isTyping = value.isNotEmpty;
                              });
                              if (value.isNotEmpty) {
                                context.read<TutorialCubit>().searchTutorials(
                                  query: value,
                                );
                              }
                            },
                            focusNode: _searchFocusNode,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12.w,
                                horizontal: 12.w,
                              ),
                              hintText: 'Search video tutorial',
                              hintStyle: TextStyle(
                                color: AppColors.searchHintColor,
                                fontSize: 12.sp,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppColors.searchIconColor,
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.08),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.w),
                                borderSide: BorderSide(
                                  color: Colors.grey[200]!.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.w),
                                borderSide: BorderSide(
                                  color: Colors.grey[200]!.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                !_isSearchFocused
                    ? Expanded(
                      child: SingleChildScrollView(
                        physics: ClampingScrollPhysics(),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                left: horizontalPadding.w,
                                right: horizontalPadding.w,

                                bottom: 16.h,
                              ),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.darkScaffoldColor,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "BROWSE BY CATEGORY",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Gap(10.h),
                                  SizedBox(
                                    height: 90.h,
                                    child: ListView(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 0.w,
                                      ),

                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      children: [
                                        CategoryItem(
                                          title: 'Upper Body',
                                          image: 'upper_body.png',
                                        ),
                                        Gap(16.w),
                                        CategoryItem(
                                          title: 'Lower Body',
                                          image: 'lower_body.png',
                                        ),
                                        Gap(16.w),
                                        CategoryItem(
                                          title: "Arms",
                                          image: 'arms.png',
                                        ),
                                        Gap(16.w),
                                        CategoryItem(
                                          title: "All",
                                          image: 'all.png',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Gap(24.h),
                            TutorialsForYou(),
                            Gap(24.h),
                            _TutorialBrowse(),
                          ],
                        ),
                      ),
                    )
                    : Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding.w,
                        ),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:
                              state is TutorialsLoaded
                                  ? AppColors.lightScaffoldColor
                                  : AppColors.darkScaffoldColor,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            state is TutorialsLoading
                                ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 100.h),
                                    child: CircularProgressIndicator(
                                      color: AppColors.lightTextColor,
                                    ),
                                  ),
                                )
                                : state is TutorialsLoaded
                                ? Container(
                                  child: Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Gap(16.h),
                                        Text(
                                          "140 RESULTS FOUND",
                                          style: TextStyle(
                                            color: AppColors.darkTextColor,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Expanded(
                                          child: ListView.separated(
                                            padding: EdgeInsets.only(top: 16.h),
                                            itemCount: state.tutorials.length,
                                            separatorBuilder:
                                                (context, index) => Gap(16.h),
                                            itemBuilder: (context, index) {
                                              final tutorial =
                                                  state.tutorials[index];
                                              return Container(
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 110.w,
                                                      height: 70.h,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6.w,
                                                            ),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                                color:
                                                                    Colors
                                                                        .grey[300],
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                    Gap(12.w),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          tutorial.title,
                                                          style: TextStyle(
                                                            color:
                                                                AppColors
                                                                    .darkTextColor,
                                                            fontSize: 14.sp,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                        Gap(4.h),
                                                        Text(
                                                          formatDuration(
                                                            Duration(
                                                              seconds:
                                                                  tutorial
                                                                      .durationSeconds,
                                                            ),
                                                          ),
                                                          style: TextStyle(
                                                            color: AppColors
                                                                .darkTextColor
                                                                .withValues(
                                                                  alpha: 0.7,
                                                                ),
                                                            fontSize: 12.sp,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        Gap(4.h),
                                                        Row(
                                                          children:
                                                              state
                                                                  .tutorials[index]
                                                                  .bodyParts
                                                                  .map(
                                                                    (
                                                                      part,
                                                                    ) => Text(
                                                                      "$part ",
                                                                      style: TextStyle(
                                                                        color: AppColors.darkTextColor.withValues(
                                                                          alpha:
                                                                              0.7,
                                                                        ),
                                                                        fontSize:
                                                                            12.sp,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  )
                                                                  .toList(),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "RECENT SEARCHES",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Gap(16.h),
                                    ColumnBuilder(
                                      itemCount: 5,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            bottom: 16.h,
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                "Full Body Workout",
                                                style: TextStyle(
                                                  color: AppColors
                                                      .lightTextColor
                                                      .withValues(alpha: 0.7),
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                              Spacer(),
                                              Icon(
                                                Icons.close,
                                                color: AppColors.lightTextColor
                                                    .withValues(alpha: 0.7),
                                                size: 16.h,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
      ),
    );
  }
}

class CategoryItem extends StatefulWidget {
  const CategoryItem({
    super.key,
    this.isSelected = false,
    required this.title,
    required this.image,
  });
  final String title;
  final String image;
  final bool isSelected;
  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      onTapDown: (details) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (details) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedScale(
        duration: Duration(milliseconds: 100),
        scale: _isPressed ? 0.95 : 1.0,
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 100),
          opacity: _isPressed ? 0.7 : 1.0,
          child: Container(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                  child: Image.asset(
                    'assets/images/${widget.image}',
                    width: 32.w,
                    height: 32.w,
                  ),
                ),
                Gap(8.h),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: AppColors.lightTextColor.withValues(alpha: 0.8),
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TutorialBrowse extends StatelessWidget {
  _TutorialBrowse({super.key});

  List<String> categories = ['ARMS', "LOWER BODY", "UPPER BODY", "FULL BODY"];
  @override
  Widget build(BuildContext context) {
    return ColumnBuilder(
      crossAxisAlignment: CrossAxisAlignment.start,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w),
                child: Text(
                  "${categories[index]} TUTORIALS",
                  style: TextStyle(
                    color: AppColors.darkTextColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Gap(10.h),
              SizedBox(
                height: 180.h,
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding.w,
                  ),
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: [
                    TutorialBox(),
                    Gap(10.w),
                    TutorialBox(),
                    Gap(10.w),
                    TutorialBox(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
