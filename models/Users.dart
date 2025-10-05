// A simple typed model for the resume JSON response.

class User {
  final String name;
  final List<String> skills;
  final List<String> projects;

  User({
    required this.name,
    required this.skills,
    required this.projects,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // defensive parsing: ensure lists are lists of strings
    List<String> parseStringList(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
      }
      return <String>[];
    }

    return User(
      name: (json['name'] ?? '').toString(),
      skills: parseStringList(json['skills']),
      projects: parseStringList(json['projects']),
    );
  }
}
