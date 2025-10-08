// providers.dart
import 'dart:async'; // <-- needed for TimeoutException
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'models/user.dart';

/// ---------- CUSTOMIZATION PROVIDERS ----------

// Font size (default 16)
final fontSizeProvider = StateProvider<double>((ref) => 16.0);

// Font color (default black)
final fontColorProvider = StateProvider<Color>((ref) => Colors.black);

// Background color (default white)
final backgroundColorProvider = StateProvider<Color>((ref) => Colors.white);

/// ---------- HTTP CLIENT (shared, pooled) ----------

final httpClientProvider = Provider<http.Client>((ref) {
  final ioHttp = HttpClient()
    ..maxConnectionsPerHost = 6
    ..idleTimeout = const Duration(seconds: 15);

  final client = IOClient(ioHttp);

  ref.onDispose(() {
    try {
      client.close();
    } catch (_) {}
  });

  return client;
});

/// ---------- RESUME FETCHING PROVIDER (fixed name in URL) ----------

/// This provider fetches the resume for the fixed name "Alice" embedded in the path.
/// Example URL: https://expressjs-api-resume-random.onrender.com/resume/Alice
final resumeProvider = FutureProvider<User>((ref) async {
  final client = ref.watch(httpClientProvider);
  final uri = Uri.parse(
    "https://expressjs-api-resume-random.onrender.com/resume/Alice",
  );

  const int maxAttempts = 3;
  Duration backoff = const Duration(milliseconds: 500);

  for (int attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      final response = await client.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } on TimeoutException catch (te) {
      debugPrint('Request timed out (attempt $attempt): $te');
      if (attempt == maxAttempts) rethrow;
    } catch (e) {
      debugPrint('Error fetching resume (attempt $attempt): $e');
      if (attempt == maxAttempts) {
        // fallback mock data
        return User(
          name: 'Alice',
          skills: ['Flutter', 'Dart'],
          projects: [
            Project(
              title: 'Resume App Demo',
              description: 'Sample project for testing fallback data.',
              startDate: '2023-01-01',
              endDate: '2023-06-30',
            ),
          ],
        );
      }
    }

    await Future.delayed(backoff);
    backoff *= 2;
  }

  // Safety fallback
  return User(
    name: 'Alice',
    skills: ['Flutter', 'Dart'],
    projects: [],
  );
});
