import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class CustomizationControls extends ConsumerWidget {
  const CustomizationControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(fontSizeProvider);
    final fontColor = ref.watch(fontColorProvider);
    final backgroundColor = ref.watch(backgroundColorProvider);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Customize Resume",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),

            // Font Size
            Row(
              children: [
                const Text("Font Size: "),
                Expanded(
                  child: Slider(
                    min: 10,
                    max: 30,
                    divisions: 20,
                    value: fontSize,
                    onChanged: (val) =>
                        ref.read(fontSizeProvider.notifier).state = val,
                  ),
                ),
                Text(fontSize.toStringAsFixed(0)),
              ],
            ),
            const SizedBox(height: 10),

            // Font Color Picker
            Row(
              children: [
                const Text("Font Color: "),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () =>
                      _pickColor(context, ref, fontColorProvider, fontColor),
                  child: CircleAvatar(backgroundColor: fontColor),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Background Color Picker
            Row(
              children: [
                const Text("Background: "),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _pickColor(
                      context, ref, backgroundColorProvider, backgroundColor),
                  child: CircleAvatar(backgroundColor: backgroundColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _pickColor(BuildContext context, WidgetRef ref,
      StateProvider<Color> provider, Color currentColor) {
    showDialog(
      context: context,
      builder: (_) {
        Color tempColor = currentColor;
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (c) => tempColor = c,
              enableAlpha: false,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(provider.notifier).state = tempColor;
                Navigator.pop(context);
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }
}
