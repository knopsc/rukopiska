import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:saber/components/toolbar/size_picker.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/pen_preset.dart';
import 'package:saber/data/tools/pencil.dart';
import 'package:saber/data/tools/shape_pen.dart';
import 'package:saber/i18n/strings.g.dart';

class PenModal extends StatefulWidget {
  const PenModal({
    super.key,
    required this.getTool,
    required this.setTool,
    required this.onClose,
  });

  final Tool Function() getTool;
  final void Function(Pen) setTool;
  final VoidCallback onClose;

  @override
  State<PenModal> createState() => _PenModalState();
}

class _PenModalState extends State<PenModal> {
  void _applyPreset(Pen currentPen, dynamic presetStow) {
    final PenPreset preset = presetStow.value;
    setState(() {
      currentPen.options =
          currentPen.options.copyWith(size: preset.size, streamline: preset.streamline);
      currentPen.color = Color(preset.color);
      if (currentPen.icon == Pen.fountainPenIcon) {
        stows.lastFountainPenOptions.value = currentPen.options;
        stows.lastFountainPenColor.value = preset.color;
      } else if (currentPen.icon == Pen.ballpointPenIcon) {
        stows.lastBallpointPenOptions.value = currentPen.options;
        stows.lastBallpointPenColor.value = preset.color;
      }
    });
  }

  void _savePreset(BuildContext context, Pen currentPen, dynamic presetStow) {
    setState(() {
      presetStow.value = PenPreset(
        size: currentPen.options.size,
        streamline: currentPen.options.streamline,
        color: currentPen.color.toARGB32(),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Пресет сохранён'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Widget _buildPresetButton(Pen currentPen, dynamic presetStow) {
    final PenPreset preset = presetStow.value;
    return GestureDetector(
      onTap: () => _applyPreset(currentPen, presetStow),
      onLongPress: () => _savePreset(context, currentPen, presetStow),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        alignment: Alignment.center,
        child: Container(
          width: preset.size.clamp(4.0, 24.0),
          height: preset.size.clamp(4.0, 24.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(preset.color),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Tool currentTool = widget.getTool();
    final Pen currentPen;
    if (currentTool is Pen) {
      currentPen = currentTool;
    } else {
      return const SizedBox();
    }

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  currentPen.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
              ],
            ),
            if (currentPen is! Highlighter && currentPen is! Pencil) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () => setState(() {
                      widget.setTool(Pen.fountainPen());
                    }),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          Pen.currentPen.icon == Pen.fountainPenIcon
                          ? ColorScheme.of(context).secondary
                          : ColorScheme.of(context).onSurface,
                      backgroundColor:
                          Pen.currentPen.icon == Pen.fountainPenIcon
                          ? Theme.of(context)
                                .colorScheme
                                .secondary
                                .withValues(alpha: 0.1)
                          : Colors.transparent,
                      shape: const CircleBorder(),
                    ),
                    tooltip: t.editor.pens.fountainPen,
                    icon: SvgPicture.asset(
                      'assets/images/scribble_fountain.svg',
                      width: 32,
                      height: 32 / 508 * 374,
                      theme: SvgTheme(
                        currentColor:
                            Pen.currentPen.icon == Pen.fountainPenIcon
                            ? ColorScheme.of(context).secondary
                            : ColorScheme.of(context).onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      widget.setTool(Pen.ballpointPen());
                    }),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          Pen.currentPen.icon == Pen.ballpointPenIcon
                          ? ColorScheme.of(context).secondary
                          : ColorScheme.of(context).onSurface,
                      backgroundColor:
                          Pen.currentPen.icon == Pen.ballpointPenIcon
                          ? Theme.of(context)
                                .colorScheme
                                .secondary
                                .withValues(alpha: 0.1)
                          : Colors.transparent,
                      shape: const CircleBorder(),
                    ),
                    tooltip: t.editor.pens.ballpointPen,
                    icon: SvgPicture.asset(
                      'assets/images/scribble_ballpoint.svg',
                      width: 32,
                      height: 32 / 508 * 374,
                      theme: SvgTheme(
                        currentColor:
                            Pen.currentPen.icon == Pen.ballpointPenIcon
                            ? ColorScheme.of(context).secondary
                            : ColorScheme.of(context).onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      widget.setTool(ShapePen());
                    }),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          Pen.currentPen.icon == ShapePen.shapePenIcon
                          ? ColorScheme.of(context).secondary
                          : ColorScheme.of(context).onSurface,
                      backgroundColor:
                          Pen.currentPen.icon == ShapePen.shapePenIcon
                          ? Theme.of(context)
                                .colorScheme
                                .secondary
                                .withValues(alpha: 0.1)
                          : Colors.transparent,
                      shape: const CircleBorder(),
                    ),
                    tooltip: t.editor.pens.shapePen,
                    icon: const FaIcon(ShapePen.shapePenIcon),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Толщина'),
                const Spacer(),
                Text('${currentPen.options.size.round()}'),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: currentPen.options.size,
                    min: currentPen.sizeMin,
                    max: currentPen.sizeMax,
                    divisions: currentPen.sizeStepsBetweenMinAndMax,
                    onChanged: (value) => setState(() {
                      currentPen.options =
                          currentPen.options.copyWith(size: value);
                      if (currentPen.icon == Pen.fountainPenIcon) {
                        stows.lastFountainPenOptions.value =
                            currentPen.options;
                      } else if (currentPen.icon == Pen.ballpointPenIcon) {
                        stows.lastBallpointPenOptions.value =
                            currentPen.options;
                      }
                    }),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => setState(() {
                        final newValue =
                            (currentPen.options.size + currentPen.sizeStep)
                                .clamp(currentPen.sizeMin, currentPen.sizeMax);
                        currentPen.options =
                            currentPen.options.copyWith(size: newValue);
                        if (currentPen.icon == Pen.fountainPenIcon) {
                          stows.lastFountainPenOptions.value =
                              currentPen.options;
                        } else if (currentPen.icon == Pen.ballpointPenIcon) {
                          stows.lastBallpointPenOptions.value =
                              currentPen.options;
                        }
                      }),
                      child: const Icon(Icons.keyboard_arrow_up, size: 16),
                    ),
                    InkWell(
                      onTap: () => setState(() {
                        final newValue =
                            (currentPen.options.size - currentPen.sizeStep)
                                .clamp(currentPen.sizeMin, currentPen.sizeMax);
                        currentPen.options =
                            currentPen.options.copyWith(size: newValue);
                        if (currentPen.icon == Pen.fountainPenIcon) {
                          stows.lastFountainPenOptions.value =
                              currentPen.options;
                        } else if (currentPen.icon == Pen.ballpointPenIcon) {
                          stows.lastBallpointPenOptions.value =
                              currentPen.options;
                        }
                      }),
                      child: const Icon(Icons.keyboard_arrow_down, size: 16),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Стабилизация'),
                const Spacer(),
                Text('${(currentPen.options.streamline * 10).round()}'),
                const SizedBox.square(dimension: 2),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => setState(() {
                        final newValue = (currentPen.options.streamline + 0.1)
                            .clamp(0.0, 1.0);
                        currentPen.options =
                            currentPen.options.copyWith(streamline: newValue);
                        if (currentPen.icon == Pen.fountainPenIcon) {
                          stows.lastFountainPenOptions.value =
                              currentPen.options;
                        } else if (currentPen.icon == Pen.ballpointPenIcon) {
                          stows.lastBallpointPenOptions.value =
                              currentPen.options;
                        }
                      }),
                      child: const Icon(Icons.keyboard_arrow_up, size: 16),
                    ),
                    InkWell(
                      onTap: () => setState(() {
                        final newValue = (currentPen.options.streamline - 0.1)
                            .clamp(0.0, 1.0);
                        currentPen.options =
                            currentPen.options.copyWith(streamline: newValue);
                        if (currentPen.icon == Pen.fountainPenIcon) {
                          stows.lastFountainPenOptions.value =
                              currentPen.options;
                        } else if (currentPen.icon == Pen.ballpointPenIcon) {
                          stows.lastBallpointPenOptions.value =
                              currentPen.options;
                        }
                      }),
                      child: const Icon(Icons.keyboard_arrow_down, size: 16),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (currentPen is! Highlighter && currentPen is! Pencil)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPresetButton(currentPen, stows.penPreset1),
                  _buildPresetButton(currentPen, stows.penPreset2),
                  _buildPresetButton(currentPen, stows.penPreset3),
                ],
              ),
          ],
        ),
      ),
    );
  }
}