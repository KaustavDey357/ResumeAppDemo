import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../providers.dart';
import 'customization_controls.dart';
import '../location.dart';

class ResumeScreen extends ConsumerWidget {
  const ResumeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(fontSizeProvider);
    final fontColor = ref.watch(fontColorProvider);
    final bgColor = ref.watch(backgroundColorProvider);

    // fetch data directly from FutureProvider
    final resumeAsync = ref.watch(resumeProvider('Kaustav'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Generator'),
        leading: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(resumeProvider('Kaustav')),
            tooltip: 'Refresh Resume',
          ),
        actions: [
  Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: const GetLocation(),
  ),
],

      ),
      body: Container(
        color: bgColor,
        child: Column(
          children: [
            const CustomizationControls(),
            Expanded(
              child: resumeAsync.when(
                data: (User user) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _formatUser(user),
                      style: TextStyle(
                        fontSize: fontSize,
                        color: fontColor,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatUser(User u) {
    final skills =
        u.skills.isNotEmpty ? u.skills.join(', ') : 'No skills listed.';
    final projects =
        u.projects.isNotEmpty ? u.projects.join(', ') : 'No projects listed.';
    return '''
Name: ${u.name}

Skills:
  ${u.skills.join(', ')}

Projects:
  ${u.projects.join(', ')}
''';
  }
}
