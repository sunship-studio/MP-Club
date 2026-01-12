import 'package:flutter/material.dart';
import 'package:mpc_admin_app/app/models/Exercise.dart';

// Modern Search Bar with glassmorphism effect
class ModernSearchBar extends StatefulWidget {
  TextEditingController controller;
  final Function(String) onChanged;

  ModernSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<ModernSearchBar> createState() => _ModernSearchBarState();
}

class _ModernSearchBarState extends State<ModernSearchBar> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,

      style: TextStyle(
        fontSize: 16,
        fontFamily: 'SF-Pro',
        fontWeight: FontWeight.w500,
        color: Theme.of(context).textTheme.bodyLarge!.color,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).cardTheme.color,
        isDense: true,
        prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 24),
        suffixIcon:
            widget.controller.text.isNotEmpty
                ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[600], size: 20),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onChanged('');
                  },
                )
                : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        hintText: 'Search exercises...',
        hintStyle: TextStyle(
          fontSize: 16,
          fontFamily: 'SF-Pro',
          color: Colors.grey[500],
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

// Modern Text Input with icon
class ModernTextInput extends StatefulWidget {
  final String hintText;
  final IconData? icon;
  final Function(String) onChanged;
  final TextEditingController? controller;
  final String initialValue;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const ModernTextInput({
    super.key,
    required this.hintText,
    this.controller,
    this.icon,
    required this.onChanged,
    this.initialValue = '',
    this.validator,
    this.keyboardType,
  });

  @override
  State<ModernTextInput> createState() => _ModernTextInputState();
}

class _ModernTextInputState extends State<ModernTextInput> {
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller!.text = widget.initialValue;
  }

  @override
  void didUpdateWidget(ModernTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue &&
        _controller!.text != widget.initialValue) {
      _controller!.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      onChanged: widget.onChanged,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      style: TextStyle(
        fontSize: 16,
        fontFamily: 'SF-Pro',
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.bodyLarge!.color,
      ),
      decoration: InputDecoration(
        fillColor: Theme.of(context).cardTheme.color,
        isDense: true,
        prefixIcon:
            widget.icon != null
                ? Icon(
                  widget.icon,
                  color: Theme.of(context).iconTheme.color,
                  size: 22,
                )
                : null,
        border: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        errorStyle: const TextStyle(
          fontSize: 13,
          fontFamily: 'SF-Pro',
          fontWeight: FontWeight.w600,

          height: 2.5, // Increase for more vertical spacing
        ),
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: 16,
          fontFamily: 'SF-Pro',
          color: Theme.of(context).textTheme.bodyMedium!.color,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}

// Modern Price Input
class ModernPriceInput extends StatefulWidget {
  final Function(double) onChanged;
  final double initialValue;
  final String? Function(String?)? validator;

  const ModernPriceInput({
    super.key,
    required this.onChanged,
    this.initialValue = 0,
    this.validator,
  });

  @override
  State<ModernPriceInput> createState() => _ModernPriceInputState();
}

class _ModernPriceInputState extends State<ModernPriceInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue > 0 ? widget.initialValue.toString() : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      onChanged: (value) {
        final price = double.tryParse(value) ?? 0;
        widget.onChanged(price);
      },
      validator: widget.validator,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(
        fontSize: 18,
        fontFamily: 'SF-Pro',
        fontWeight: FontWeight.w700,
        color: Theme.of(context).textTheme.bodyLarge!.color,
      ),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        isDense: true,
        fillColor: Theme.of(context).cardTheme.color,
        filled: true,
        border: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        errorStyle: const TextStyle(
          fontSize: 13,
          fontFamily: 'SF-Pro',
          fontWeight: FontWeight.w600,
          height: 2.5, // Increase for more vertical spacing
        ),
        hintText: 'Set Price',
        prefixText: '€ ',
        prefixStyle: TextStyle(
          fontSize: 18,
          fontFamily: 'SF-Pro',
          fontWeight: FontWeight.w700,
          color: Theme.of(context).iconTheme.color,
        ),
        hintStyle: TextStyle(
          fontSize: 16,
          fontFamily: 'SF-Pro',
          color: Theme.of(context).textTheme.bodyMedium!.color,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}

// Modern Day Selector with smooth scrolling
class ModernDaySelector extends StatelessWidget {
  final int selectedDay;
  final List days;
  final Function(int) onDaySelected;
  final VoidCallback onAddDay;

  const ModernDaySelector({
    super.key,
    required this.selectedDay,
    required this.days,
    required this.onDaySelected,
    required this.onAddDay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...days.asMap().entries.map((entry) {
              final index = entry.key;
              final isSelected = selectedDay == index;
              return _DayChip(
                label: 'Day ${index + 1}',
                isSelected: isSelected,
                onTap: () => onDaySelected(index),
              );
            }),
            _AddDayButton(onPressed: onAddDay),
          ],
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          color: isSelected ? null : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontFamily: 'SF-Pro',
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _AddDayButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddDayButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(
              context,
            ).textTheme.bodyMedium!.color!.withOpacity(0.0),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Icon(
          Icons.add,
          color: Theme.of(context).iconTheme.color,
          size: 20,
        ),
      ),
    );
  }
}

// Modern Save Button with gradient
class ModernSaveButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  const ModernSaveButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  @override
  State<ModernSaveButton> createState() => _ModernSaveButtonState();
}

class _ModernSaveButtonState extends State<ModernSaveButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.save_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'SF-Pro',
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modern Button (used for retry, etc)
class ModernButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final Color? color;

  const ModernButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'SF-Pro',
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        shadowColor: (color ?? Theme.of(context).primaryColor).withValues(
          alpha: 0.4,
        ),
      ),
    );
  }
}

// Empty State Widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 64, color: Colors.grey[400]),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'SF-Pro',
              color: Colors.grey[700],
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'SF-Pro',
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Modern Suggested Exercise Card
class ModernSuggestedExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;

  const ModernSuggestedExerciseCard({
    super.key,
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.add_circle_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'SF-Pro',
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to add',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'SF-Pro',
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
