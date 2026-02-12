import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import 'profile_preferences_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool fromLogin;
  const ProfileSetupScreen({super.key, required this.fromLogin});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _department = 'CS';
  String _pillar = 'CSD';
  String _year = 'Year 1';
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      if (user.department.isNotEmpty) _department = user.department;
      if (user.pillar.isNotEmpty) _pillar = user.pillar;
      if (user.year.isNotEmpty) _year = user.year;
    }
    _initialized = true;
  }

  Future<void> _saveProfile(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final channels = Provider.of<ChannelsProvider>(context, listen: false);
    final user = auth.user;
    if (user == null) return;

    await auth.saveCoreProfile(
      department: user.role == 'staff' ? _department : null,
      pillar: user.role == 'student' ? _pillar : null,
      year: user.role == 'student' ? _year : null,
    );
    channels.setUser(auth.user);

    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePreferencesScreen(fromLogin: widget.fromLogin),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final theme = Theme.of(context);
    if (user == null) return const Scaffold(body: SizedBox.shrink());

    final isStaff = user.role == 'staff';
    final isStudent = user.role == 'student';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fromLogin ? 'Set up profile' : 'Edit profile'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    'Complete your profile once, then edit anytime.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Signed in as ${user.email} (${user.role})',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  if (isStaff) ...[
                    DropdownButtonFormField<String>(
                      initialValue: _department,
                      decoration: const InputDecoration(
                        labelText: 'Department (Staff)',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'CS', child: Text('CS')),
                        DropdownMenuItem(value: 'EE', child: Text('EE')),
                        DropdownMenuItem(value: 'ME', child: Text('ME')),
                        DropdownMenuItem(value: 'BA', child: Text('BA')),
                        DropdownMenuItem(
                          value: 'Student Affairs',
                          child: Text('Student Affairs'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _department = v ?? 'CS'),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Please select a department'
                          : null,
                    ),
                  ],
                  if (isStudent) ...[
                    DropdownButtonFormField<String>(
                      initialValue: _pillar,
                      decoration: const InputDecoration(
                        labelText: 'Pillar (Student)',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'CSD',
                          child: Text('CSD'),
                        ),
                        DropdownMenuItem(
                          value: 'DAI',
                          child: Text('DAI'),
                        ),
                        DropdownMenuItem(
                          value: 'EPD',
                          child: Text('EPD'),
                        ),
                        DropdownMenuItem(
                          value: 'ESD',
                          child: Text('ESD'),
                        ),
                        DropdownMenuItem(
                          value: 'ASD',
                          child: Text('ASD'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _pillar = v ?? 'CSD'),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Please select a pillar'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _year,
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Year 1', child: Text('Year 1')),
                        DropdownMenuItem(value: 'Year 2', child: Text('Year 2')),
                        DropdownMenuItem(value: 'Year 3', child: Text('Year 3')),
                        DropdownMenuItem(value: 'Year 4', child: Text('Year 4')),
                      ],
                      onChanged: (v) => setState(() => _year = v ?? 'Year 1'),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Please select a year'
                          : null,
                    ),
                  ],
                  if (!isStaff && !isStudent) ...[
                    Text(
                      'No extra profile fields required for this role.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _saveProfile(context),
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
