/// AI-generated wholely or partially with OpenAI Codex.
library;

import 'package:flutter/material.dart';
import 'package:saber/data/ocr/smart_pen_settings.dart';

class SmartPenModal extends StatefulWidget {
  const SmartPenModal({super.key});

  @override
  State<SmartPenModal> createState() => _SmartPenModalState();
}

class _SmartPenModalState extends State<SmartPenModal> {
  final settings = SmartPenSettings.instance;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 4,
          children: [
            DropdownButton<String>(
              value: settings.fontFamily,
              items: const [
                DropdownMenuItem(value: 'Neucha', child: Text('Neucha')),
                DropdownMenuItem(
                  value: 'AtkinsonHyperlegibleNext',
                  child: Text('Atkinson (Latin only)'),
                ),
                DropdownMenuItem(value: 'FiraMono', child: Text('Fira Mono')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(
                  () => settings.update(() => settings.fontFamily = value),
                );
              },
            ),
            FilterChip(
              label: const Text('Auto size'),
              selected: settings.automaticSize,
              onSelected: (value) => setState(
                () => settings.update(() => settings.automaticSize = value),
              ),
            ),
            SizedBox(
              width: 180,
              child: Slider(
                value: settings.automaticSize
                    ? settings.sizeScale
                    : settings.fixedSize,
                min: settings.automaticSize ? 0.7 : 14,
                max: settings.automaticSize ? 1.4 : 120,
                divisions: settings.automaticSize ? 14 : 106,
                label: settings.automaticSize
                    ? '${(settings.sizeScale * 100).round()}%'
                    : settings.fixedSize.round().toString(),
                onChanged: (value) => setState(
                  () => settings.update(() {
                    if (settings.automaticSize) {
                      settings.sizeScale = value;
                    } else {
                      settings.fixedSize = value;
                    }
                  }),
                ),
              ),
            ),
            FilterChip(
              label: const Text('Bold'),
              selected: settings.bold,
              onSelected: (value) =>
                  setState(() => settings.update(() => settings.bold = value)),
            ),
            FilterChip(
              label: const Text('Italic'),
              selected: settings.italic,
              onSelected: (value) => setState(
                () => settings.update(() => settings.italic = value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
