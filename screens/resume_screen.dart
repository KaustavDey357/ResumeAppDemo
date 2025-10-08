// resume_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';
import '../models/user.dart';
import '../providers.dart';
import 'customization_controls.dart';

class ResumeScreen extends ConsumerStatefulWidget {
  const ResumeScreen({super.key});

  @override
  ConsumerState<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends ConsumerState<ResumeScreen> {
  final Location _location = Location();
  StreamSubscription<LocationData>? _sub;

  double lat = 0.0;
  double lon = 0.0;

  @override
  void initState() {
    super.initState();
    _initLocation();
    // refresh the fixed-name provider on startup
    Future.microtask(() => ref.refresh(resumeProvider));
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _sub = _location.onLocationChanged.listen((locationData) {
      if (!mounted) return;
      setState(() {
        lat = locationData.latitude ?? 0.0;
        lon = locationData.longitude ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = ref.watch(fontSizeProvider);
    final fontColor = ref.watch(fontColorProvider);
    final bgColor = ref.watch(backgroundColorProvider);

    // watch the provider (fixed name "Alice" in URL)
    final asyncValue = ref.watch(resumeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Resume Demo"),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (_) => const Padding(
                padding: EdgeInsets.all(12),
                child: CustomizationControls(),
              ),
            ),
          ),
          // Optional: manual refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(resumeProvider),
            tooltip: 'Refresh resume',
          ),
        ],
      ),
      body: Container(
        color: bgColor,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LOCATION FEED AT TOP
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: Colors.blueAccent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Lat: ${lat.toStringAsFixed(5)}, Lon: ${lon.toStringAsFixed(5)}",
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Resume Info (auto-fetched)
            Expanded(
              child: asyncValue.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Text(
                    'Failed to load data.\n$err',
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ),
                data: (user) => SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    _formatUser(user),
                    style: TextStyle(fontSize: fontSize, color: fontColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatUser(User u) {
    final skills = u.skills.isEmpty ? "No skills" : u.skills.join(", ");
    final projects = u.projects.isEmpty ? "No projects" : u.projects.join(", ");
    return """
Name: ${u.name}

Skills:
  $skills

Projects:
  $projects
""";
  }
}
