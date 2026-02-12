class CampusUser {
  final String id;
  final String email;
  final String name;
  final String role; // student, staff, hod, osa, admin
  final String department;
  final int clearance; // 1=student, 2=staff, 3=hod/osa, 4=admin

  CampusUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.department,
    required this.clearance,
  });

  factory CampusUser.fromJson(Map<String, dynamic> json) => CampusUser(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String,
        role: json['role'] as String,
        department: json['department'] as String,
        clearance: (json['clearance'] as int?) ?? 1,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role,
        'department': department,
        'clearance': clearance,
      };
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
