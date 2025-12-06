import 'package:coolicons/coolicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mpc_mobile_app/core/constants.dart';
import 'package:mpc_mobile_app/core/theme/app_colors.dart';
import 'package:mpc_mobile_app/cubits/auth.dart';
import 'package:mpc_mobile_app/cubits/tutorials.dart';
import 'package:mpc_mobile_app/data/models/Exercise.dart';
import 'package:mpc_mobile_app/presentation/widgets/column_builder.dart';
import 'package:mpc_mobile_app/presentation/widgets/tutorial_box.dart';
import 'package:mpc_mobile_app/presentation/widgets/tutorials_for_you.dart';
import 'package:mpc_mobile_app/services/recent_searches.dart';

class TutorialsScreen extends StatefulWidget {
  const TutorialsScreen({super.key});

  @override
  State<TutorialsScreen> createState() => _TutorialsScreenState();
}

class _TutorialsScreenState extends State<TutorialsScreen> {
  late final FocusNode _searchFocusNode;
  late final TextEditingController _searchController;
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode()..addListener(_onSearchFocusChanged);
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchFocusNode
      ..removeListener(_onSearchFocusChanged)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchFocusChanged() {
    setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
  }

  void _onSearchChanged(String value) {
    final cubit = context.read<TutorialCubit>();
    if (value.isEmpty) {
      cubit.clearSearch();
    } else {
      cubit.searchTutorials(query: value);
    }
  }

  Future<void> _onRefresh() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      await context.read<TutorialCubit>().fetchTutorialsSection(
        userId: authState.user.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _AppBar(
            isSearchFocused: _isSearchFocused,
            onBackPressed: _searchFocusNode.unfocus,
          ),
          _SearchBar(
            focusNode: _searchFocusNode,
            controller: _searchController,
            onChanged: _onSearchChanged,
          ),
          Expanded(
            child: BlocBuilder<TutorialCubit, TutorialState>(
              builder: (context, state) {
                return _isSearchFocused
                    ? _SearchContent(
                      state: state,
                      isTyping: _searchController.text.isNotEmpty,
                    )
                    : state is TutorialsByCategoryLoaded
                    ? _TutorialSearchByCategory()
                    : _BrowseContent(state: state, onRefresh: _onRefresh);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({required this.isSearchFocused, required this.onBackPressed});

  final bool isSearchFocused;
  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(color: AppColors.darkScaffoldColor),
      child: Row(
        children: [
          Gap(horizontalPadding.w),
          if (isSearchFocused)
            GestureDetector(
              onTap: onBackPressed,
              child: Icon(Icons.arrow_back, size: 28.w, color: Colors.white),
            )
          else
            SizedBox(width: 28.w),
          Expanded(
            child: Center(
              child: Text(
                isSearchFocused
                    ? 'Search Tutorials'.toUpperCase()
                    : 'Tutorials Screen'.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(width: 64.w),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.focusNode,
    required this.controller,
    required this.onChanged,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: const BoxDecoration(color: AppColors.darkScaffoldColor),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        style: TextStyle(color: Colors.white, fontSize: 12.sp),
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
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.searchIconColor,
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.08),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.w),
            borderSide: BorderSide(
              color: Colors.grey[200]!.withValues(alpha: 0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.w),
            borderSide: BorderSide(
              color: Colors.grey[200]!.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrowseContent extends StatelessWidget {
  const _BrowseContent({required this.state, required this.onRefresh});

  final TutorialState state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      backgroundColor: AppColors.darkScaffoldColor,
      color: AppColors.blueColor,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            _CategorySection(),
            if (state case TutorialsSectionLoaded(:final tutorialsSection))
              Column(
                children: [
                  Gap(24.h),
                  TutorialsForYou(forYou: tutorialsSection.forYou),
                  Gap(24.h),
                  _TutorialsByBodyPart(byBodyPart: tutorialsSection.byBodyPart),
                ],
              )
            else
              Padding(
                padding: EdgeInsets.only(top: 100.h),
                child: const CircularProgressIndicator(
                  color: AppColors.darkScaffoldColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  static const _categories = [
    ('All', 'all.png'),
    ('Upper Body', 'upper_body.png'),
    ('Lower Body', 'lower_body.png'),
    ('Arms', 'arms.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: horizontalPadding.w,
        right: horizontalPadding.w,
        bottom: 16.h,
      ),
      width: double.infinity,
      decoration: const BoxDecoration(color: AppColors.darkScaffoldColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BROWSE BY CATEGORY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          Gap(10.h),
          SizedBox(
            height: 90.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => Gap(16.w),
              itemBuilder: (context, index) {
                final (title, image) = _categories[index];
                return _CategoryItem(title: title, image: image);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchContent extends StatelessWidget {
  const _SearchContent({required this.state, required this.isTyping});

  final TutorialState state;
  final bool isTyping;

  Color get _backgroundColor {
    if (state is TutorialsLoading) return AppColors.darkScaffoldColor;
    if (state is TutorialsError) return AppColors.darkScaffoldColor;
    if (!isTyping) return AppColors.darkScaffoldColor;
    if (state case TutorialsSectionLoaded(:final searchResults)) {
      if (searchResults == null || searchResults.isEmpty) {
        return AppColors.darkScaffoldColor;
      }
      return AppColors.lightScaffoldColor;
    }
    return AppColors.darkScaffoldColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w),
      width: double.infinity,
      decoration: BoxDecoration(color: _backgroundColor),
      child: switch (state) {
        TutorialsLoading() => const _LoadingView(),
        TutorialsError(:final message) => _ErrorView(message: message),
        TutorialsSectionLoaded() when !isTyping => const _RecentSearchesView(),
        TutorialsSectionLoaded(:final searchResults?)
            when searchResults.isNotEmpty =>
          _SearchResultsView(results: searchResults),
        TutorialsSectionLoaded(:final searchResults?)
            when searchResults.isEmpty =>
          const _EmptySearchView(),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 100.h),
        child: CircularProgressIndicator(color: AppColors.lightTextColor),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 100.h),
      child: Center(
        child: Text(
          'Error: $message',
          style: const TextStyle(color: AppColors.lightTextColor),
        ),
      ),
    );
  }
}

class _EmptySearchView extends StatelessWidget {
  const _EmptySearchView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 100.h),
      child: const Center(
        child: Text(
          'No results found.',
          style: TextStyle(color: AppColors.lightTextColor),
        ),
      ),
    );
  }
}

class _RecentSearchesView extends StatefulWidget {
  const _RecentSearchesView();

  @override
  State<_RecentSearchesView> createState() => _RecentSearchesViewState();
}

class _RecentSearchesViewState extends State<_RecentSearchesView> {
  List<Exercise> _recentSearches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final searches = await RecentSearchesService.getRecentSearches();
    if (mounted) {
      setState(() {
        _recentSearches = searches;
        _isLoading = false;
      });
    }
  }

  Future<void> _removeSearch(String exerciseId) async {
    await RecentSearchesService.removeSearch(exerciseId);
    await _loadRecentSearches();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50.h),
          child: CircularProgressIndicator(color: AppColors.lightTextColor),
        ),
      );
    }

    if (_recentSearches.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECENT SEARCHES',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          Gap(24.h),
          Center(
            child: Text(
              'No recent searches yet',
              style: TextStyle(
                color: AppColors.lightTextColor.withValues(alpha: 0.5),
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECENT SEARCHES',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        Gap(16.h),
        ColumnBuilder(
          itemCount: _recentSearches.length,
          itemBuilder: (context, index) {
            final exercise = _recentSearches[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: GestureDetector(
                onTap: () async {
                  await RecentSearchesService.saveSearch(exercise);
                  if (context.mounted) {
                    context.push('/tutorial', extra: exercise);
                  }
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: TextStyle(
                          color: AppColors.lightTextColor.withValues(
                            alpha: 0.7,
                          ),
                          fontSize: 14.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Gap(8.w),
                    GestureDetector(
                      onTap: () => _removeSearch(exercise.id),
                      child: Icon(
                        Icons.close,
                        color: AppColors.lightTextColor.withValues(alpha: 0.7),
                        size: 16.h,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SearchResultsView extends StatelessWidget {
  const _SearchResultsView({required this.results});

  final List<Exercise> results;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(16.h),
        Text(
          '${results.length} RESULTS FOUND',
          style: TextStyle(
            color: AppColors.darkTextColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.only(top: 16.h),
            itemCount: results.length,
            separatorBuilder: (_, __) => Gap(16.h),
            itemBuilder: (context, index) {
              return _SearchResultItem(exercise: results[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  const _SearchResultItem({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Save to recent searches
        await RecentSearchesService.saveSearch(exercise);
        if (context.mounted) {
          context.push('/tutorial', extra: exercise);
        }
      },
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 110.w,
              height: 70.h,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                image: DecorationImage(
                  image: NetworkImage(exercise.imageUrl),
                  fit: BoxFit.cover,
                  alignment: Alignment(0, -0.2),
                ),
                borderRadius: BorderRadius.circular(6.w),
              ),
            ),
            Gap(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: TextStyle(
                      color: AppColors.darkTextColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gap(4.h),
                  Text(
                    Constants.formatDuration(
                      Duration(seconds: exercise.videoLengthSeconds),
                    ),
                    style: TextStyle(
                      color: AppColors.darkTextColor.withValues(alpha: 0.7),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Gap(4.h),
                  Text(
                    exercise.bodyParts.join(', '),
                    style: TextStyle(
                      color: AppColors.darkTextColor.withValues(alpha: 0.7),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatefulWidget {
  const _CategoryItem({required this.title, required this.image});

  final String title;
  final String image;

  @override
  State<_CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<_CategoryItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.title == 'All') {
          context.read<TutorialCubit>().clearCategoryFilter();
        } else {
          context.read<TutorialCubit>().searchByCategory(
            category: widget.title,
          );
        }
      },
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 100),
        scale: _isPressed ? 0.95 : 1.0,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: _isPressed ? 0.7 : 1.0,
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
    );
  }
}

class _TutorialsByBodyPart extends StatelessWidget {
  const _TutorialsByBodyPart({required this.byBodyPart});

  final List<dynamic> byBodyPart;

  @override
  Widget build(BuildContext context) {
    return ColumnBuilder(
      crossAxisAlignment: CrossAxisAlignment.start,
      itemCount: 5,
      itemBuilder: (context, index) {
        final section = byBodyPart[index];
        final bodyPart = section['bodyPart'] as String;
        final exercises = section['exercises'] as List;

        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w),
                child: Text(
                  '${bodyPart.toUpperCase()} TUTORIALS',
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
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding.w,
                  ),
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: exercises.length,
                  separatorBuilder: (_, __) => Gap(10.w),
                  itemBuilder: (context, itemIndex) {
                    return TutorialBox(
                      exercise: Exercise.fromJson(exercises[itemIndex]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TutorialSearchByCategory extends StatelessWidget {
  const _TutorialSearchByCategory({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TutorialCubit, TutorialState>(
      builder: (context, state) {
        state = state as TutorialsByCategoryLoaded;
        return Column(
          children: [
            _CategorySection(),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 12.h,
                  horizontal: horizontalPadding.w,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.read<TutorialCubit>().clearCategoryFilter();
                          },
                          child: Icon(
                            Icons.arrow_back,
                            size: 20.w,
                            color: AppColors.darkTextColor,
                          ),
                        ),
                        Gap(12.w),
                        Expanded(
                          child:
                              state.tutorialsByCategory.isEmpty
                                  ? Text(
                                    "No tutorials found in ${state.selectedCategory} category."
                                        .toUpperCase(),
                                    style: TextStyle(
                                      color: AppColors.darkTextColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                  : Text(
                                    "${state.selectedCategory} Tutorials"
                                        .toUpperCase(),
                                    style: TextStyle(
                                      color: AppColors.darkTextColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                        ),
                      ],
                    ),
                    Gap(10.h),
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: state.tutorialsByCategory.length,
                        separatorBuilder: (_, __) => Gap(16.h),
                        itemBuilder: (context, index) {
                          return _TutorialBoxByCategory(
                            exercise:
                                (state as TutorialsByCategoryLoaded)
                                    .tutorialsByCategory[index],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TutorialBoxByCategory extends StatefulWidget {
  const _TutorialBoxByCategory({super.key, required this.exercise});
  final Exercise exercise;

  @override
  State<_TutorialBoxByCategory> createState() => _TutorialBoxByCategoryState();
}

class _TutorialBoxByCategoryState extends State<_TutorialBoxByCategory> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/tutorial', extra: widget.exercise);
      },
      onTapDown:
          (details) => setState(() {
            _isPressed = true;
          }),
      onTapUp:
          (details) => setState(() {
            _isPressed = false;
          }),
      onTapCancel:
          () => setState(() {
            _isPressed = false;
          }),

      child: AnimatedScale(
        duration: Duration(milliseconds: 100),
        scale: _isPressed ? 0.98 : 1.0,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),

          height: 420.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    widget.exercise.name,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      letterSpacing: -0.4,
                    ),
                  ),
                  Gap(0.h),
                  Text(
                    "${Constants.formatDuration(Duration(seconds: widget.exercise.videoLengthSeconds))} mins",
                    style: TextStyle(
                      color: AppColors.textSubColor,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              Gap(12.h),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10.r),
                    image: DecorationImage(
                      image: NetworkImage(widget.exercise.imageUrl),
                      fit: BoxFit.cover,
                      alignment: Alignment(0, 0.1),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Spacer(),
                          Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withAlpha(0),
                                  Colors.white.withAlpha(200),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Coolicons.play_arrow,
                              size: 16.h,
                              color: Colors.white.withAlpha(200),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
