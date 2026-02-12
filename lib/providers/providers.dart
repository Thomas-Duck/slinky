import 'package:flutter/material.dart';
import '../models/models.dart';

class AuthProvider with ChangeNotifier {
  CampusUser? _user;
  bool _isLoading = false;
  bool _isOnline = true; // Demo: current user is online

  CampusUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isOnline => _isOnline;

  void setOnline(bool value) {
    _isOnline = value;
    notifyListeners();
  }

  Future<void> loginWithEmail(String email, String otp) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    String role = 'student';
    const String dept = 'CS';
    int clearance = 1;

    if (email.contains('hod')) {
      role = 'hod';
      clearance = 3;
    }
    if (email.contains('staff')) {
      role = 'staff';
      clearance = 2;
    }
    if (email.contains('admin')) {
      role = 'admin';
      clearance = 4;
    }

    _user = CampusUser(
      id: email,
      email: email,
      name: email.split('@')[0],
      role: role,
      department: dept,
      clearance: clearance,
    );

    _isLoading = false;
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}

class ChannelsProvider with ChangeNotifier {
  List<Channel> _channels = [];
  String? _selectedChannelId;
  String? _selectedPostId;
  CampusUser? _user;

  // View tracking: postId -> set of viewer user IDs
  final Map<String, Set<String>> _postViewers = {};
  static const int _totalAppUsers = 24;

  List<Channel> get visibleChannels => _channels
      .where((c) => _user != null && _user!.clearance >= c.clearance)
      .toList();
  String? get selectedChannelId => _selectedChannelId;
  String? get selectedPostId => _selectedPostId;
  CampusUser? get user => _user;
  int get totalAppUsers => _totalAppUsers;

  int getPostViewCount(String postId) =>
      _postViewers[postId]?.length ?? 0;

  void recordPostView(String postId) {
    if (_user == null) return;
    _postViewers[postId] ??= {};
    _postViewers[postId]!.add(_user!.id);
    notifyListeners();
  }

  /// Mock author IDs for demo posts (postId -> authorId)
  String? getPostAuthorId(String postId) {
    const authors = {
      '1': 'staff@college.edu',
      '2': 'staff@college.edu',
      '3': 'student@college.edu',
    };
    return authors[postId];
  }

  bool isCurrentUserPostAuthor(String postId) =>
      _user != null && getPostAuthorId(postId) == _user!.id;

  void setUser(CampusUser? user) {
    _user = user;
    notifyListeners();
  }

  bool userCanPostIn(Channel channel) =>
      _user != null && _user!.clearance >= channel.clearance;

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
    notifyListeners();
  }
}
