import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'models/user.dart';

//API call is directly inside this FutureProvider.family
final resumeProvider = FutureProvider.family<User, String>((ref, name) async {
  final url = 'https://expressjs-api-resume-random.onrender.com/resume?name=$name';
  final uri = Uri.parse(url);

  final response = await http.get(uri);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return User.fromJson(data);
  } else {
    throw Exception('Failed to fetch resume (${response.statusCode})');
  }
});

// UI state providers for customization
final fontSizeProvider = StateProvider<double>((ref) => 16.0);
final fontColorProvider = StateProvider<Color>((ref) => Colors.black);
final backgroundColorProvider = StateProvider<Color>((ref) => Colors.white);
