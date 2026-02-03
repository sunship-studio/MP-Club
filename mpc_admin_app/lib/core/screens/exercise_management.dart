import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpc_admin_app/app/bloc/exercises/cubit.dart';
import 'package:mpc_admin_app/app/bloc/exercises/state.dart';
import 'package:mpc_admin_app/app/models/Exercise.dart';
import 'package:mpc_admin_app/core/widgets/plan_editor/plan_editor_widgets.dart';

class ExerciseManagementScreen extends StatelessWidget {
  const ExerciseManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExercisesCubit, ExercisesState>(
      listener: (context, state) {
        if (state is ExerciseSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ExercisesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showExerciseDialog(context, null),
            icon: const Icon(Icons.add),
            label: const Text('Add Exercise'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ExercisesState state) {
    if (state is ExercisesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ExerciseSaving) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(value: state.uploadProgress),
            const SizedBox(height: 16),
            Text(
              state.uploadProgress != null
                  ? 'Uploading... ${(state.uploadProgress! * 100).toInt()}%'
                  : 'Saving exercise...',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (state is ExercisesLoaded) {
      return Column(
        children: [
          _buildSearchAndFilter(context, state),
          Expanded(
            child:
                state.filteredExercises.isEmpty
                    ? Center(
                      child: Text(
                        state.searchQuery.isNotEmpty ||
                                state.selectedBodyPart != null
                            ? 'No exercises found matching your filters'
                            : 'No exercises yet. Add your first exercise!',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    )
                    : _buildExercisesList(context, state.filteredExercises),
          ),
        ],
      );
    }

    if (state is ExercisesError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<ExercisesCubit>().loadExercises(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSearchAndFilter(BuildContext context, ExercisesLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search exercises...',
              prefixIcon: const Icon(Icons.search),
              filled: true,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              context.read<ExercisesCubit>().filterExercises(query: value);
            },
          ),
          const SizedBox(height: 12),
          // Body part filter chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: state.selectedBodyPart == null,
                  onSelected: (_) {
                    context.read<ExercisesCubit>().filterExercises(
                      query: state.searchQuery,
                      bodyPart: null,
                    );
                  },
                ),
                const SizedBox(width: 8),
                ...ExercisesCubit.bodyPartOptions.map((bodyPart) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(bodyPart),
                      selected: state.selectedBodyPart == bodyPart,
                      onSelected: (_) {
                        context.read<ExercisesCubit>().filterExercises(
                          query: state.searchQuery,
                          bodyPart: bodyPart,
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${state.filteredExercises.length} exercises',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList(BuildContext context, List<Exercise> exercises) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return _ExerciseCard(
          exercise: exercise,
          onEdit: () => _showExerciseDialog(context, exercise),
          onDelete: () => _confirmDelete(context, exercise),
        );
      },
    );
  }

  void _showExerciseDialog(BuildContext context, Exercise? exercise) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<ExercisesCubit>(),
          child: _ExerciseFormDialog(exercise: exercise),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Exercise exercise) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Exercise'),
          content: Text('Are you sure you want to delete "${exercise.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<ExercisesCubit>().deleteExercise(exercise.id);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExerciseCard({
    required this.exercise,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[900],
              ),
              clipBehavior: Clip.antiAlias,
              child:
                  exercise.videoUrl != null
                      ? Image.network(
                        exercise.videoUrl!.replaceAll('.mp4', '.jpg'),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                      : _buildPlaceholder(),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children:
                        exercise.bodyParts
                            .map(
                              (bp) => Chip(
                                label: Text(
                                  bp,
                                  style: const TextStyle(fontSize: 10),
                                ),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                  ),
                  if (exercise.videoUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.videocam,
                            size: 14,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Video attached',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Actions
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: const Icon(Icons.fitness_center, size: 32, color: Colors.grey),
    );
  }
}

class _ExerciseFormDialog extends StatefulWidget {
  final Exercise? exercise;

  const _ExerciseFormDialog({this.exercise});

  @override
  State<_ExerciseFormDialog> createState() => _ExerciseFormDialogState();
}

class _ExerciseFormDialogState extends State<_ExerciseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  List<String> _selectedBodyParts = [];
  String? _videoPath;
  String? _imagePath;
  String? _existingVideoUrl;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.exercise?.description ?? '',
    );
    _selectedBodyParts = widget.exercise?.bodyParts.toList() ?? [];
    _existingVideoUrl = widget.exercise?.videoUrl;
    _existingImageUrl = widget.exercise?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.exercise != null;

    return Dialog(
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      isEditing ? 'Edit Exercise' : 'Add Exercise',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Form content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Exercise Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      // Body parts
                      const Text(
                        'Body Parts *',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            ExercisesCubit.bodyPartOptions.map((bp) {
                              final isSelected = _selectedBodyParts.contains(
                                bp,
                              );
                              return FilterChip(
                                label: Text(bp),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedBodyParts.add(bp);
                                    } else {
                                      _selectedBodyParts.remove(bp);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                      ),
                      if (_selectedBodyParts.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Please select at least one body part',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 24),
                      // Video upload
                      const Text(
                        'Exercise Video',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildFileSelector(
                        icon: Icons.video_call_outlined,
                        label:
                            _videoPath != null
                                ? 'Video selected: ${_videoPath!.split('/').last}'
                                : _existingVideoUrl != null
                                ? 'Current video attached'
                                : 'Select video file',
                        onTap: _pickVideo,
                        hasFile:
                            _videoPath != null || _existingVideoUrl != null,
                        onClear: () {
                          setState(() {
                            _videoPath = null;
                            _existingVideoUrl = null;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Image upload
                      if (_existingImageUrl != null && _imagePath == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _existingImageUrl!,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ModernButton(
                      label: isEditing ? 'Update' : 'Create',
                      onPressed: _submit,
                      icon: isEditing ? Icons.save : Icons.add,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileSelector({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool hasFile,
    required VoidCallback onClear,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: hasFile ? Colors.green : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: hasFile ? Colors.green[700] : Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasFile)
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: onClear,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null) {
      setState(() {
        _videoPath = result.files.single.path;
      });
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        _imagePath = result.files.single.path;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBodyParts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one body part'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cubit = context.read<ExercisesCubit>();
    Navigator.pop(context);

    if (widget.exercise != null) {
      // Update existing
      cubit.updateExercise(
        id: widget.exercise!.id,
        name: _nameController.text,
        description: _descriptionController.text,
        bodyParts: _selectedBodyParts,
        videoPath: _videoPath,
        imagePath: _imagePath,
        existingVideoUrl: _existingVideoUrl,
        existingImageUrl: _existingImageUrl,
      );
    } else {
      // Create new
      cubit.createExercise(
        name: _nameController.text,
        description: _descriptionController.text,
        bodyParts: _selectedBodyParts,
        videoPath: _videoPath,
        imagePath: _imagePath,
      );
    }
  }
}
