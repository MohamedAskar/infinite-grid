import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditGridControls extends StatefulWidget {
  const EditGridControls({
    super.key,
    required this.gridOffset,
    required this.spacing,
    required this.enableMomentumScrolling,
    required this.onGridOffsetChanged,
    required this.onSpacingChanged,
    required this.onCenterPressed,
    required this.onDonePressed,
    required this.onSubmitted,
    required this.onMomentumScrollingChanged,
  });

  final double gridOffset;
  final double spacing;
  final bool enableMomentumScrolling;
  final ValueChanged<double> onGridOffsetChanged;
  final ValueChanged<double> onSpacingChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onCenterPressed;
  final VoidCallback onDonePressed;
  final ValueChanged<bool> onMomentumScrollingChanged;

  @override
  State<EditGridControls> createState() => _EditGridControlsState();
}

class _EditGridControlsState extends State<EditGridControls> {
  final TextEditingController _controller = TextEditingController();

  void _onCenterPressed() {
    widget.onCenterPressed();
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;

    final width = MediaQuery.sizeOf(context).width;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: min(width, 320),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: onSurface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: onSurface.withValues(alpha: 0.1),
                blurRadius: 30,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Grid',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: surfaceColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Grid Offset Slider
              _SliderSection(
                title: 'Grid Offset',
                value: widget.gridOffset,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                onChanged: widget.onGridOffsetChanged,
              ),

              const SizedBox(height: 12),

              // Spacing Slider
              _SliderSection(
                title: 'Spacing',
                value: widget.spacing,
                min: 0.0,
                max: 64.0,
                divisions: 16,
                onChanged: widget.onSpacingChanged,
              ),

              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Momentum Scrolling',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: surfaceColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                value: widget.enableMomentumScrolling,
                onChanged: widget.onMomentumScrollingChanged,
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Text(
                    'Navigate to item:',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: surfaceColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                        child: Container(
                          decoration: BoxDecoration(
                            color: onSurface.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.5,
                              ),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: onSurface.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _controller,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: surfaceColor,
                            ),
                            decoration: InputDecoration(
                              hintText: 'index',
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: surfaceColor.withValues(alpha: 0.8),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onFieldSubmitted: widget.onSubmitted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  CustomButton(
                    icon: const Icon(Icons.center_focus_strong),
                    onPressed: _onCenterPressed,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      label: 'Save Changes',
                      onPressed: widget.onDonePressed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderSection extends StatelessWidget {
  const _SliderSection({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String title;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: surfaceColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: surfaceColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: theme.colorScheme.primary,
            inactiveTrackColor: surfaceColor.withValues(alpha: 0.4),
            thumbColor: theme.colorScheme.primary,
            overlayColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            padding: EdgeInsets.symmetric(vertical: 4),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    this.label,
    this.icon,
  });

  final VoidCallback onPressed;
  final String? label;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final surfaceColor = theme.colorScheme.surface;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: onSurface.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: onSurface.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  spacing: 8,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null)
                      IconTheme(
                        data: IconThemeData(color: surfaceColor),
                        child: icon!,
                      ),
                    if (label != null)
                      Text(
                        label!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: surfaceColor,
                          fontWeight: FontWeight.w600,
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
