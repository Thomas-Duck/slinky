import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import 'main_screen.dart';

class ProfilePreferencesScreen extends StatefulWidget {
  final bool fromLogin;
  const ProfilePreferencesScreen({super.key, required this.fromLogin});

  @override
  State<ProfilePreferencesScreen> createState() =>
      _ProfilePreferencesScreenState();
}

class _ProfilePreferencesScreenState extends State<ProfilePreferencesScreen> {
  static const List<String> _topicOptions = [
    'machine learning',
    'data science',
    'cybersecurity',
    'mobile development',
    'web development',
    'cloud computing',
    'devops',
    'ui/ux design',
    'product management',
    'robotics',
    'iot',
    'embedded systems',
    'networking',
    'databases',
    'blockchain',
    'project management',
    'public speaking',
    'research writing',
    'leadership',
    'business analysis',
    'finance tech',
    'health tech',
    'game development',
    'software testing',
    'api design',
  ];

  static const List<String> _studentEthicsOptions = [
    'collaborative',
    'disciplined',
    'self-driven',
    'curious',
    'reliable',
    'adaptable',
    'punctual',
    'respectful',
  ];

  static const List<String> _staffEthicsOptions = [
    'professional communication',
    'confidentiality',
    'accountability',
    'mentorship mindset',
    'policy compliance',
    'timely delivery',
    'stakeholder alignment',
    'documentation discipline',
  ];

  static const List<String> _studentValuesOptions = [
    'integrity',
    'growth',
    'community',
    'inclusivity',
    'responsibility',
    'creativity',
    'service',
    'excellence',
  ];

  static const List<String> _staffValuesOptions = [
    'professionalism',
    'equity',
    'student-centered',
    'evidence-based practice',
    'institutional trust',
    'ethical leadership',
    'continuous improvement',
    'quality assurance',
  ];

  final Set<String> _selectedTopics = {};
  final Set<String> _selectedEthics = {};
  final Set<String> _selectedValues = {};
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _selectedTopics.addAll(user.interests);
      _selectedEthics.addAll(user.workEthics);
      _selectedValues.addAll(user.personalValues);
    }
    _initialized = true;
  }

  Future<void> _save(BuildContext context) async {
    if (_selectedTopics.isEmpty ||
        _selectedEthics.isEmpty ||
        _selectedValues.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please select at least one topic, ethic, and value.'),
        ),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final channels = Provider.of<ChannelsProvider>(context, listen: false);
    await auth.savePreferences(
      interests: _selectedTopics.toList(),
      workEthics: _selectedEthics.toList(),
      personalValues: _selectedValues.toList(),
    );
    channels.setUser(auth.user);

    if (!context.mounted) return;
    if (widget.fromLogin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final theme = Theme.of(context);
    if (user == null) return const Scaffold(body: SizedBox.shrink());

    final isProfessional = user.role != 'student';
    final ethicsOptions =
        isProfessional ? _staffEthicsOptions : _studentEthicsOptions;
    final valuesOptions =
        isProfessional ? _staffValuesOptions : _studentValuesOptions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                isProfessional
                    ? 'Select professional topics, work ethics, and values.'
                    : 'Select topics, personal work ethics, and values.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              _SectionChips(
                title: 'Topics',
                subtitle: 'Choose from a wide variety of topics.',
                options: _topicOptions,
                selected: _selectedTopics,
                onToggle: (value) => setState(() {
                  if (_selectedTopics.contains(value)) {
                    _selectedTopics.remove(value);
                  } else {
                    _selectedTopics.add(value);
                  }
                }),
              ),
              const SizedBox(height: 16),
              _SectionChips(
                title:
                    isProfessional ? 'Professional Work Ethics' : 'Work Ethics',
                subtitle: isProfessional
                    ? 'Select ethics that reflect your professional style.'
                    : 'Select ethics that reflect how you work.',
                options: ethicsOptions,
                selected: _selectedEthics,
                onToggle: (value) => setState(() {
                  if (_selectedEthics.contains(value)) {
                    _selectedEthics.remove(value);
                  } else {
                    _selectedEthics.add(value);
                  }
                }),
              ),
              const SizedBox(height: 16),
              _SectionChips(
                title: 'Values',
                subtitle: isProfessional
                    ? 'Choose professional values that guide your decisions.'
                    : 'Choose values that matter to you.',
                options: valuesOptions,
                selected: _selectedValues,
                onToggle: (value) => setState(() {
                  if (_selectedValues.contains(value)) {
                    _selectedValues.remove(value);
                  } else {
                    _selectedValues.add(value);
                  }
                }),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _save(context),
                child: Text(widget.fromLogin ? 'Finish setup' : 'Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionChips extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _SectionChips({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.bodySmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options
                .map(
                  (option) => FilterChip(
                    label: Text(option),
                    selected: selected.contains(option),
                    onSelected: (_) => onToggle(option),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
