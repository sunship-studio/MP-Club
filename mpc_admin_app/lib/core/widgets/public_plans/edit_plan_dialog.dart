import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:mpc_admin_app/app/bloc/public_plans/cubit.dart';
import 'package:mpc_admin_app/app/models/Exercise.dart';
import 'package:mpc_admin_app/app/models/PublicPlan.dart';
import 'package:mpc_admin_app/app/network/api.dart';
import 'package:mpc_admin_app/core/theme/app_colors.dart';

class EditPlanDialog extends StatefulWidget {
  final PublicPlan plan;
  final Function(PublicPlan) onSave;

  const EditPlanDialog({super.key, required this.plan, required this.onSave});

  @override
  State<EditPlanDialog> createState() => _EditPlanDialogState();
}

class _EditPlanDialogState extends State<EditPlanDialog> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  final TextEditingController _searchController = TextEditingController();

  List<Exercise> _allExercises = [];
  List<Exercise> _filteredExercises = [];
  late List<String> _selectedExercises;
  String? _excelFilePath;
  String? _excelFileName;
  bool _isUploading = false;
  bool _isLoadingExercises = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plan.name);
    _priceController = TextEditingController(
      text: widget.plan.price.toString(),
    );
    _selectedExercises = [...widget.plan.listOfExercises];
    _excelFileName = widget.plan.excelFileUrl.split('/').last;

    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      final response = await apiService.get('/exercises');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        setState(() {
          _allExercises = data.map((json) => Exercise.fromJson(json)).toList();
          _filteredExercises = _allExercises;
          _isLoadingExercises = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingExercises = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load exercises')));
      }
    }
  }

  void _filterExercises(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredExercises = _allExercises;
      } else {
        _filteredExercises =
            _allExercises
                .where(
                  (exercise) =>
                      exercise.name.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  Future<void> _pickExcelFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _excelFilePath = result.files.single.path;
        _excelFileName = result.files.single.name;
      });
    }
  }

  Future<void> _savePlan() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a plan name')));
      return;
    }

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a valid price')));
      return;
    }

    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one exercise')),
      );
      return;
    }

    setState(() => _isUploading = true);

    String? excelUrl = widget.plan.excelFileUrl;
    if (_excelFilePath != null) {
      final uploadedUrl = await context
          .read<PublicPlansCubit>()
          .uploadExcelFile(_excelFilePath!);
      if (uploadedUrl == null) {
        setState(() => _isUploading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload Excel file')),
          );
        }
        return;
      }
      excelUrl = uploadedUrl;
    }

    final updatedPlan = PublicPlan(
      id: widget.plan.id,
      name: _nameController.text.trim(),
      listOfExercises: _selectedExercises,
      excelFileUrl: excelUrl,
      price: price,
      createdAt: widget.plan.createdAt,
      updatedAt: DateTime.now(),
    );

    widget.onSave(updatedPlan);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkScaffoldColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Plan',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontFamily: 'SF-Pro',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            Gap(16.h),
            TextField(
              controller: _nameController,
              style: TextStyle(color: Colors.white, fontFamily: 'SF-Pro'),
              decoration: InputDecoration(
                labelText: 'Plan Name',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: AppColors.darkCardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            Gap(12.h),
            TextField(
              controller: _priceController,
              style: TextStyle(color: Colors.white, fontFamily: 'SF-Pro'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Price',
                labelStyle: TextStyle(color: Colors.white70),
                prefixText: '\$',
                prefixStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: AppColors.darkCardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            Gap(12.h),
            GestureDetector(
              onTap: _pickExcelFile,
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.darkCardColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: _excelFileName != null ? Colors.green : Colors.grey,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.file_upload,
                      color:
                          _excelFileName != null ? Colors.green : Colors.grey,
                    ),
                    Gap(12.w),
                    Expanded(
                      child: Text(
                        _excelFileName ?? 'Upload Excel File (Optional)',
                        style: TextStyle(
                          color:
                              _excelFileName != null
                                  ? Colors.green
                                  : Colors.white70,
                          fontFamily: 'SF-Pro',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_excelFilePath != null)
                      Text(
                        'New file',
                        style: TextStyle(
                          color: Colors.orange,
                          fontFamily: 'SF-Pro',
                          fontSize: 12.sp,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Gap(16.h),
            Text(
              'Select Exercises',
              style: TextStyle(
                fontSize: 16.sp,
                fontFamily: 'SF-Pro',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(8.h),
            TextField(
              controller: _searchController,
              onChanged: _filterExercises,
              style: TextStyle(color: Colors.white, fontFamily: 'SF-Pro'),
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                hintStyle: TextStyle(color: Colors.white54),
                prefixIcon: Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: AppColors.darkCardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            Gap(8.h),
            if (_selectedExercises.isNotEmpty) ...[
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children:
                    _selectedExercises.map((exerciseName) {
                      return RawChip(
                        label: Text(exerciseName),
                        deleteIcon: Icon(
                          Icons.close,
                          size: 16.w,
                          color: Colors.white,
                        ),
                        onDeleted: () {
                          setState(() {
                            _selectedExercises.remove(exerciseName);
                          });
                        },
                        backgroundColor: AppColors.blueColor,
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontFamily: 'SF-Pro',
                          fontSize: 12.sp,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      );
                    }).toList(),
              ),
              Gap(8.h),
            ],
            Expanded(
              child:
                  _isLoadingExercises
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        itemCount: _filteredExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = _filteredExercises[index];
                          final isSelected = _selectedExercises.contains(
                            exercise.name,
                          );

                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedExercises.add(exercise.name);
                                } else {
                                  _selectedExercises.remove(exercise.name);
                                }
                              });
                            },
                            title: Text(
                              exercise.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'SF-Pro',
                              ),
                            ),
                            activeColor: AppColors.blueColor,
                            checkColor: Colors.white,
                            tileColor: AppColors.darkCardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          );
                        },
                      ),
            ),
            Gap(16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _savePlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueColor,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child:
                    _isUploading
                        ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: 'SF-Pro',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
