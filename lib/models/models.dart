class CampusUser {
  final String id;
  final String email;
  final String name;
  final String role; // student, staff, hod, osa, admin
  final String department;
  final String pillar;
  final int clearance; // 1=student, 2=staff, 3=hod/osa, 4=admin
  final String year;
  final List<String> interests;
  final List<String> workEthics;
  final List<String> personalValues;

  CampusUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.department,
    this.pillar = '',
    required this.clearance,
    this.year = '',
    this.interests = const [],
    this.workEthics = const [],
    this.personalValues = const [],
  });

  factory CampusUser.fromJson(Map<String, dynamic> json) => CampusUser(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String,
        role: json['role'] as String,
        department: json['department'] as String,
        pillar: (json['pillar'] as String?) ?? '',
        clearance: (json['clearance'] as int?) ?? 1,
        year: (json['year'] as String?) ?? '',
        interests: ((json['interests'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        workEthics: ((json['workEthics'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        personalValues: ((json['personalValues'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role,
        'department': department,
        'pillar': pillar,
        'clearance': clearance,
        'year': year,
        'interests': interests,
        'workEthics': workEthics,
        'personalValues': personalValues,
      };

  CampusUser copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? department,
    String? pillar,
    int? clearance,
    String? year,
    List<String>? interests,
    List<String>? workEthics,
    List<String>? personalValues,
  }) {
    return CampusUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      department: department ?? this.department,
      pillar: pillar ?? this.pillar,
      clearance: clearance ?? this.clearance,
      year: year ?? this.year,
      interests: interests ?? this.interests,
      workEthics: workEthics ?? this.workEthics,
      personalValues: personalValues ?? this.personalValues,
    );
  }
}

class Channel {
  final String id;
  final String name;
  final String department;
  final int clearance;
  final String createdBy;
  final List<String> rolesConcerned;

  Channel({
    required this.id,
    required this.name,
    required this.department,
    required this.clearance,
    required this.createdBy,
    this.rolesConcerned = const [],
  });
}

class Comment {
  final String id;
  final String postId;
  final String authorId;
  final String authorRole;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorRole,
    required this.text,
    required this.createdAt,
  });
}

class Post {
  final String id;
  final String channelId;
  final String title;
  final String body;
  final String authorId;
  final String authorRole;
  final List<String> rolesConcerned;
  final int clearance;
  final bool isProposal;
  final List<String> proposalTargets;
  final Map<String, String> proposalResponses;
  final List<Comment> comments;
  final int viewCount;
  final List<String> viewerIds;

  Post({
    required this.id,
    required this.channelId,
    required this.title,
    required this.body,
    required this.authorId,
    required this.authorRole,
    this.rolesConcerned = const [],
    this.clearance = 1,
    this.isProposal = false,
    this.proposalTargets = const [],
    this.proposalResponses = const {},
    this.comments = const [],
    this.viewCount = 0,
    this.viewerIds = const [],
  });
}
