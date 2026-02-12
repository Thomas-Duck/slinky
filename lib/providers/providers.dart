import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/models.dart';

class BackendRuntime {
  static bool firebaseReady = false;
}

class AppSettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleThemeMode() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

class StudyBuddyMatch {
  final CampusUser user;
  final int score;
  final List<String> sharedInterests;
  final List<String> sharedWorkEthics;
  final List<String> sharedValues;

  StudyBuddyMatch({
    required this.user,
    required this.score,
    required this.sharedInterests,
    required this.sharedWorkEthics,
    required this.sharedValues,
  });
}

class SessionRequestSummary {
  final String requestId;
  final String toUserId;
  final String status;
  final String? postContext;
  final DateTime updatedAt;

  SessionRequestSummary({
    required this.requestId,
    required this.toUserId,
    required this.status,
    required this.updatedAt,
    this.postContext,
  });
}

class PostFeedback {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String text;
  final DateTime createdAt;

  PostFeedback({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  factory PostFeedback.fromMap(
      String id, String postId, Map<String, dynamic> data) {
    final createdRaw = data['createdAt'];
    DateTime createdAt = DateTime.now();
    if (createdRaw is Timestamp) createdAt = createdRaw.toDate();
    if (createdRaw is DateTime) createdAt = createdRaw;
    if (createdRaw is String) {
      final parsed = DateTime.tryParse(createdRaw);
      if (parsed != null) createdAt = parsed;
    }

    return PostFeedback(
      id: id,
      postId: postId,
      authorId: (data['authorId'] as String?) ?? 'unknown',
      authorName: (data['authorName'] as String?) ?? 'Unknown',
      text: (data['text'] as String?) ?? '',
      createdAt: createdAt,
    );
  }
}

class AuthProvider with ChangeNotifier {
  CampusUser? _user;
  bool _isLoading = false;
  bool _isOnline = true; // Demo: current user is online
  static const String _institutionDomain = 'college.edu';
  static const String _profilesStorageKey = 'slinky_profiles_v1';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Map<String, CampusUser> _savedProfiles = {};
  final Map<String, SessionRequestSummary> _sessionRequestsByTarget = {};
  bool _profilesLoaded = false;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _sessionRequestsSubscription;
  final List<CampusUser> _studentDirectory = [
    CampusUser(
      id: 'amy@college.edu',
      email: 'amy@college.edu',
      name: 'amy',
      role: 'student',
      department: '',
      pillar: 'DAI',
      clearance: 1,
      year: 'Year 2',
      interests: ['ml', 'flutter', 'ui'],
      workEthics: ['collaborative', 'disciplined'],
      personalValues: ['integrity', 'growth'],
    ),
    CampusUser(
      id: 'david@college.edu',
      email: 'david@college.edu',
      name: 'david',
      role: 'student',
      department: '',
      pillar: 'CSD',
      clearance: 1,
      year: 'Year 1',
      interests: ['algorithms', 'backend', 'python'],
      workEthics: ['curious', 'self-driven'],
      personalValues: ['accountability', 'excellence'],
    ),
    CampusUser(
      id: 'nina@college.edu',
      email: 'nina@college.edu',
      name: 'nina',
      role: 'student',
      department: '',
      pillar: 'ASD',
      clearance: 1,
      year: 'Year 2',
      interests: ['iot', 'robotics', 'embedded'],
      workEthics: ['reliable', 'collaborative'],
      personalValues: ['respect', 'community'],
    ),
  ];

  CampusUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isOnline => _isOnline;
  bool get isFirebaseReady => BackendRuntime.firebaseReady;

  String getSessionRequestStatus(String toUserId) =>
      _sessionRequestsByTarget[toUserId]?.status ?? 'none';

  bool canSendSessionRequest(String toUserId) {
    final status = getSessionRequestStatus(toUserId);
    return status == 'none' || status == 'declined';
  }

  bool get requiresProfileSetup {
    final current = _user;
    if (current == null) return false;
    final hasPreferences = current.interests.isNotEmpty &&
        current.workEthics.isNotEmpty &&
        current.personalValues.isNotEmpty;
    if (current.role == 'staff') {
      return current.department.trim().isEmpty || !hasPreferences;
    }
    if (current.role == 'student') {
      return current.pillar.trim().isEmpty ||
          current.year.trim().isEmpty ||
          !hasPreferences;
    }
    return false;
  }

  List<StudyBuddyMatch> get studyBuddyMatches {
    final current = _user;
    if (current == null || current.role != 'student') return const [];

    final normalizedCurrentInterests = current.interests
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet();
    final normalizedCurrentEthics = current.workEthics
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet();
    final normalizedCurrentValues = current.personalValues
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet();

    final matches = <StudyBuddyMatch>[];
    for (final candidate in _studentDirectory) {
      if (candidate.id == current.id) continue;

      int score = 0;
      if (candidate.pillar == current.pillar) score += 4;
      if (candidate.year == current.year) score += 3;

      final candidateInterests = candidate.interests
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toSet();
      final shared = normalizedCurrentInterests
          .intersection(candidateInterests)
          .toList()
        ..sort();
      score += shared.length * 2;

      final candidateEthics = candidate.workEthics
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toSet();
      final sharedEthics = normalizedCurrentEthics
          .intersection(candidateEthics)
          .toList()
        ..sort();
      score += sharedEthics.length * 2;

      final candidateValues = candidate.personalValues
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toSet();
      final sharedValues =
          normalizedCurrentValues.intersection(candidateValues).toList()
            ..sort();
      score += sharedValues.length * 2;

      if (score > 0) {
        matches.add(StudyBuddyMatch(
          user: candidate,
          score: score,
          sharedInterests: shared,
          sharedWorkEthics: sharedEthics,
          sharedValues: sharedValues,
        ));
      }
    }

    matches.sort((a, b) => b.score.compareTo(a.score));
    return matches.take(5).toList();
  }

  void setOnline(bool value) {
    _isOnline = value;
    notifyListeners();
  }

  DateTime _asDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }

  void _startSessionRequestWatcher() {
    _sessionRequestsSubscription?.cancel();
    if (!isFirebaseReady || _user == null) return;

    _sessionRequestsSubscription = FirebaseFirestore.instance
        .collection('session_requests')
        .where('fromUserId', isEqualTo: _user!.id)
        .snapshots()
        .listen((snapshot) {
      final latestByTarget = <String, SessionRequestSummary>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final target = (data['toUserId'] as String?) ?? '';
        if (target.isEmpty) continue;
        final candidate = SessionRequestSummary(
          requestId: doc.id,
          toUserId: target,
          status: (data['status'] as String?) ?? 'pending',
          postContext: data['postContext'] as String?,
          updatedAt: _asDate(data['updatedAt'] ?? data['createdAt']),
        );

        final existing = latestByTarget[target];
        if (existing == null ||
            candidate.updatedAt.isAfter(existing.updatedAt)) {
          latestByTarget[target] = candidate;
        }
      }
      _sessionRequestsByTarget
        ..clear()
        ..addAll(latestByTarget);
      notifyListeners();
    });
  }

  Future<void> sendSessionRequest(String toUserId, {String? postContext}) async {
    if (_user == null) return;
    final now = DateTime.now();
    _sessionRequestsByTarget[toUserId] = SessionRequestSummary(
      requestId: 'local_${now.microsecondsSinceEpoch}',
      toUserId: toUserId,
      status: 'pending',
      postContext: postContext,
      updatedAt: now,
    );
    notifyListeners();

    if (!isFirebaseReady) return;
    try {
      final ref =
          await FirebaseFirestore.instance.collection('session_requests').add({
        'fromUserId': _user!.id,
        'toUserId': toUserId,
        'status': 'pending',
        'postContext': postContext,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final existing = _sessionRequestsByTarget[toUserId];
      if (existing != null) {
        _sessionRequestsByTarget[toUserId] = SessionRequestSummary(
          requestId: ref.id,
          toUserId: existing.toUserId,
          status: existing.status,
          postContext: existing.postContext,
          updatedAt: existing.updatedAt,
        );
        notifyListeners();
      }
    } catch (_) {
      // local fallback already applied
    }
  }

  Future<void> updateSessionRequestStatus(String requestId, String status) async {
    if (_user == null) return;
    final now = DateTime.now();
    for (final entry in _sessionRequestsByTarget.entries) {
      if (entry.value.requestId == requestId) {
        _sessionRequestsByTarget[entry.key] = SessionRequestSummary(
          requestId: entry.value.requestId,
          toUserId: entry.value.toUserId,
          status: status,
          postContext: entry.value.postContext,
          updatedAt: now,
        );
      }
    }
    notifyListeners();

    if (!isFirebaseReady) return;
    try {
      await FirebaseFirestore.instance
          .collection('session_requests')
          .doc(requestId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // keep local fallback state
    }
  }

  Future<void> _ensureProfilesLoaded() async {
    if (_profilesLoaded) return;
    try {
      final raw = await _storage.read(key: _profilesStorageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          _savedProfiles.clear();
          decoded.forEach((key, value) {
            if (value is Map<String, dynamic>) {
              _savedProfiles[key] = CampusUser.fromJson(value);
            } else if (value is Map) {
              _savedProfiles[key] =
                  CampusUser.fromJson(Map<String, dynamic>.from(value));
            }
          });
        }
      }
    } catch (_) {
      _savedProfiles.clear();
    }
    _profilesLoaded = true;
  }

  Future<void> _persistProfiles() async {
    final payload = <String, dynamic>{};
    _savedProfiles.forEach((key, value) {
      payload[key] = value.toJson();
    });
    await _storage.write(
      key: _profilesStorageKey,
      value: jsonEncode(payload),
    );
  }

  void _upsertStudentDirectory(CampusUser student) {
    _studentDirectory.removeWhere((u) => u.id == student.id);
    _studentDirectory.add(student);
  }

  bool _isInstitutionalEmail(String email) {
    final normalized = email.trim().toLowerCase();
    return normalized.endsWith('@$_institutionDomain');
  }

  Future<void> loginWithEmail(String email, String otp,
      {String? selectedRole}) async {
    _isLoading = true;
    notifyListeners();

    await _ensureProfilesLoaded();
    await Future.delayed(const Duration(seconds: 1));

    final normalizedEmail = email.trim().toLowerCase();
    final institutional = _isInstitutionalEmail(normalizedEmail);
    String role = selectedRole ?? 'student';
    int clearance = 1;

    // Privileged roles are auto-locked to institutional emails only.
    if (institutional && normalizedEmail.contains('hod')) {
      role = 'hod';
      clearance = 3;
    }
    if (institutional && normalizedEmail.contains('admin')) {
      role = 'admin';
      clearance = 4;
    }
    if (role != 'hod' && role != 'admin' && selectedRole == 'student') {
      role = 'student';
      clearance = 1;
    }
    if (role != 'hod' && role != 'admin' && selectedRole == 'staff') {
      role = 'staff';
      clearance = 2;
    }

    final baseUser = CampusUser(
      id: normalizedEmail,
      email: normalizedEmail,
      name: normalizedEmail.split('@')[0],
      role: role,
      department: '',
      pillar: '',
      clearance: clearance,
      year: '',
      interests: const [],
      workEthics: const [],
      personalValues: const [],
    );

    final saved = _savedProfiles[normalizedEmail];
    if (saved != null) {
      _user = saved.copyWith(
        id: baseUser.id,
        email: baseUser.email,
        name: baseUser.name,
        role: role,
        clearance: clearance,
        // Role-scoped profile fields.
        department: role == 'staff' ? saved.department : '',
        pillar: role == 'student' ? saved.pillar : '',
        year: role == 'student' ? saved.year : '',
        interests: saved.interests,
        workEthics: saved.workEthics,
        personalValues: saved.personalValues,
      );
    } else {
      _user = baseUser;
    }

    if (_user!.role == 'student' && !requiresProfileSetup) {
      _upsertStudentDirectory(_user!);
    }
    _startSessionRequestWatcher();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveCoreProfile({
    String? department,
    String? pillar,
    String? year,
  }) async {
    if (_user == null) return;
    final current = _user!;

    CampusUser updated = current;
    if (current.role == 'staff') {
      updated = current.copyWith(
        department: (department ?? '').trim(),
        pillar: '',
        year: '',
      );
    } else if (current.role == 'student') {
      updated = current.copyWith(
        department: '',
        pillar: (pillar ?? '').trim(),
        year: (year ?? '').trim(),
      );
    }

    _user = updated;
    _savedProfiles[updated.id] = updated;
    if (updated.role == 'student') {
      _upsertStudentDirectory(updated);
    }
    await _persistProfiles();
    notifyListeners();
  }

  Future<void> savePreferences({
    required List<String> interests,
    required List<String> workEthics,
    required List<String> personalValues,
  }) async {
    if (_user == null) return;
    final normalizedInterests = interests
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final normalizedEthics = workEthics
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final normalizedValues = personalValues
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final updated = _user!.copyWith(
      interests: normalizedInterests,
      workEthics: normalizedEthics,
      personalValues: normalizedValues,
    );

    _user = updated;
    _savedProfiles[updated.id] = updated;
    if (updated.role == 'student') {
      _upsertStudentDirectory(updated);
    }
    await _persistProfiles();
    notifyListeners();
  }

  void logout() {
    _sessionRequestsSubscription?.cancel();
    _sessionRequestsByTarget.clear();
    _user = null;
    notifyListeners();
  }
}

class ChannelsProvider with ChangeNotifier {
  List<Channel> _channels = [];
  List<Post> _posts = [];
  String? _selectedChannelId;
  String? _selectedPostId;
  CampusUser? _user;

  // View tracking: postId -> set of viewer user IDs
  final Map<String, Set<String>> _postViewers = {};
  final Map<String, bool> _studentChannelVisibility = {};
  final Set<String> _agendaPostIds = {};
  final Map<String, List<PostFeedback>> _localFeedbackByPost = {};
  final Map<String, StreamController<List<PostFeedback>>>
      _localFeedbackControllers = {};
  static const int _totalAppUsers = 24;

  bool get isFirebaseReady => BackendRuntime.firebaseReady;
  List<Channel> get visibleChannels {
    if (_user == null) return [];
    return _channels.where((c) {
      final clearanceAllowed = _user!.clearance >= c.clearance;
      if (!clearanceAllowed) return false;
      if (_user!.role == 'student') {
        return isChannelVisibleToStudents(c.id);
      }
      return true;
    }).toList();
  }

  String? get selectedChannelId => _selectedChannelId;
  String? get selectedPostId => _selectedPostId;
  CampusUser? get user => _user;
  int get totalAppUsers => _totalAppUsers;
  List<Post> get postsForSelectedChannel =>
      _posts.where((p) => p.channelId == _selectedChannelId).toList();

  Post? get selectedPost {
    if (_selectedPostId == null) return null;
    for (final post in _posts) {
      if (post.id == _selectedPostId) return post;
    }
    return null;
  }

  List<Post> get agendaPosts =>
      _posts.where((post) => _agendaPostIds.contains(post.id)).toList();

  int getPostViewCount(String postId) => _postViewers[postId]?.length ?? 0;

  bool get canCurrentUserManageStudentVisibility =>
      _user != null &&
      (_user!.role == 'staff' ||
          _user!.role == 'hod' ||
          _user!.role == 'admin');

  bool canManageStudentVisibility(Channel channel) =>
      canCurrentUserManageStudentVisibility && channel.clearance <= 1;

  bool isChannelVisibleToStudents(String channelId) =>
      _studentChannelVisibility[channelId] ?? true;

  void setChannelVisibleToStudents(String channelId, bool isVisible) {
    _studentChannelVisibility[channelId] = isVisible;
    notifyListeners();
  }

  bool isPostInAgenda(String postId) => _agendaPostIds.contains(postId);

  void addPostToAgenda(String postId) {
    _agendaPostIds.add(postId);
    notifyListeners();
  }

  void removePostFromAgenda(String postId) {
    _agendaPostIds.remove(postId);
    notifyListeners();
  }

  void togglePostInAgenda(String postId) {
    if (_agendaPostIds.contains(postId)) {
      _agendaPostIds.remove(postId);
    } else {
      _agendaPostIds.add(postId);
    }
    notifyListeners();
  }

  void recordPostView(String postId) {
    if (_user == null) return;
    _postViewers[postId] ??= <String>{};
    _postViewers[postId]!.add(_user!.id);
    notifyListeners();
  }

  String? getPostAuthorId(String postId) {
    for (final post in _posts) {
      if (post.id == postId) return post.authorId;
    }
    return null;
  }

  bool isCurrentUserPostAuthor(String postId) =>
      _user != null && getPostAuthorId(postId) == _user!.id;

  void setUser(CampusUser? user) {
    _user = user;
    notifyListeners();
  }

  bool userCanPostIn(Channel channel) =>
      _user != null && _user!.clearance >= channel.clearance;

  bool get canCurrentUserCreateChannels =>
      _user != null &&
      (_user!.role == 'staff' || _user!.role == 'hod' || _user!.role == 'admin');

  void selectChannel(String channelId) {
    _selectedChannelId = channelId;
    _selectedPostId = null;
    notifyListeners();
  }

  void selectPost(String? postId) {
    _selectedPostId = postId;
    if (postId != null && _user != null) {
      recordPostView(postId);
    } else {
      notifyListeners();
    }
  }

  void createChannel({
    required String name,
    required String department,
    required int clearance,
  }) {
    if (!canCurrentUserCreateChannels || _user == null) return;
    final created = Channel(
      id: 'ch_${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      department: department.trim(),
      clearance: clearance,
      createdBy: _user!.id,
    );
    _channels = [created, ..._channels];
    _selectedChannelId = created.id;
    _selectedPostId = null;
    notifyListeners();
  }

  void createPost({
    required String channelId,
    required String title,
    required String body,
    bool isProposal = false,
  }) {
    if (_user == null) return;
    final created = Post(
      id: 'post_${DateTime.now().microsecondsSinceEpoch}',
      channelId: channelId,
      title: title.trim(),
      body: body.trim(),
      authorId: _user!.id,
      authorRole: _user!.role,
      isProposal: isProposal,
    );
    _posts = [created, ..._posts];
    _selectedChannelId = channelId;
    _selectedPostId = created.id;
    notifyListeners();
  }

  StreamController<List<PostFeedback>> _controllerFor(String postId) {
    return _localFeedbackControllers.putIfAbsent(
      postId,
      () => StreamController<List<PostFeedback>>.broadcast(),
    );
  }

  List<PostFeedback> getFeedbackForPost(String postId) {
    final list = _localFeedbackByPost[postId] ?? const [];
    final copy = List<PostFeedback>.from(list);
    copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return copy;
  }

  void _emitLocalFeedback(String postId) {
    _controllerFor(postId).add(getFeedbackForPost(postId));
  }

  Future<void> loadFeedbackForPost(String postId) async {
    if (!isFirebaseReady) {
      _emitLocalFeedback(postId);
    }
  }

  Stream<List<PostFeedback>> watchFeedback(String postId) {
    if (isFirebaseReady) {
      return FirebaseFirestore.instance
          .collection('post_feedback')
          .doc(postId)
          .collection('items')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => PostFeedback.fromMap(doc.id, postId, doc.data()))
                .toList(),
          );
    }
    _emitLocalFeedback(postId);
    return _controllerFor(postId).stream;
  }

  Future<void> addFeedback(
    String postId,
    String text, {
    required CampusUser author,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    if (isFirebaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection('post_feedback')
            .doc(postId)
            .collection('items')
            .add({
          'postId': postId,
          'authorId': author.id,
          'authorName': author.name,
          'text': trimmed,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return;
      } catch (_) {
        // fall through to local fallback
      }
    }

    final item = PostFeedback(
      id: 'local_${DateTime.now().microsecondsSinceEpoch}',
      postId: postId,
      authorId: author.id,
      authorName: author.name,
      text: trimmed,
      createdAt: DateTime.now(),
    );
    final list = _localFeedbackByPost.putIfAbsent(postId, () => []);
    list.add(item);
    _emitLocalFeedback(postId);
    notifyListeners();
  }

  void loadMockChannels() {
    _channels = [
      Channel(
        id: '1',
        name: 'OSA Forum',
        department: 'Admin',
        clearance: 1,
        createdBy: 'admin',
      ),
      Channel(
        id: '2',
        name: 'CS Dept',
        department: 'CS',
        clearance: 2,
        createdBy: 'hod',
      ),
      Channel(
        id: '3',
        name: 'FYP Team A',
        department: 'CS',
        clearance: 1,
        createdBy: 'staff',
      ),
      Channel(
        id: '4',
        name: 'Staff Only',
        department: 'CS',
        clearance: 3,
        createdBy: 'hod',
      ),
    ];

    _posts = [
      Post(
        id: '1',
        channelId: '3',
        title: 'FYP Proposal - Team A',
        body:
            'Need 3 members for AI/ML project. Skills required: Python, TensorFlow. Meetings: Tue/Thu 2pm.',
        authorId: 'staff@college.edu',
        authorRole: 'staff',
        isProposal: true,
      ),
      Post(
        id: '2',
        channelId: '2',
        title: 'Class Timetable Change',
        body: 'Lab moved to Room B204 from next week onward.',
        authorId: 'staff@college.edu',
        authorRole: 'staff',
      ),
      Post(
        id: '3',
        channelId: '3',
        title: 'Project Partner Request',
        body:
            'Looking for ML expert and backend teammate for capstone project.',
        authorId: 'student@college.edu',
        authorRole: 'student',
        isProposal: true,
      ),
      Post(
        id: '4',
        channelId: '1',
        title: 'OSA Notice: Orientation',
        body: 'Orientation briefing starts at 10:00 AM in Hall A.',
        authorId: 'admin@college.edu',
        authorRole: 'admin',
      ),
    ];

    _localFeedbackByPost['1'] = [
      PostFeedback(
        id: 'seed_1',
        postId: '1',
        authorId: 'john@college.edu',
        authorName: 'John',
        text: 'Great project idea!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    ];
    _emitLocalFeedback('1');
    notifyListeners();
  }
}
