import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';

enum _SidebarTab { agenda, resources }

class _StudyResource {
  final String title;
  final String category;
  final String description;

  const _StudyResource({
    required this.title,
    required this.category,
    required this.description,
  });
}

class QuickActions extends StatefulWidget {
  const QuickActions({super.key});

  @override
  State<QuickActions> createState() => _QuickActionsState();
}

class _QuickActionsState extends State<QuickActions> {
  _SidebarTab _activeTab = _SidebarTab.agenda;

  static const List<_StudyResource> _studentResources = [
    _StudyResource(
      title: 'Academic Writing Toolkit',
      category: 'Writing',
      description: 'Citation guides, report templates, and proposal checklists.',
    ),
    _StudyResource(
      title: 'Programming Practice Bank',
      category: 'Coding',
      description: 'Curated coding drills for algorithms, APIs, and debugging.',
    ),
    _StudyResource(
      title: 'Exam Prep Planner',
      category: 'Planning',
      description: 'Weekly revision structure and spaced-repetition routines.',
    ),
    _StudyResource(
      title: 'Research Skills Starter',
      category: 'Research',
      description: 'How to scope topics, evaluate sources, and summarize papers.',
    ),
    _StudyResource(
      title: 'Presentation Skills Hub',
      category: 'Communication',
      description: 'Slide structures, speaking prompts, and demo-day prep tips.',
    ),
    _StudyResource(
      title: 'Career and Internship Prep',
      category: 'Career',
      description: 'CV checklist, portfolio prompts, and interview question bank.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final auth = Provider.of<AuthProvider>(context);
    final channels = Provider.of<ChannelsProvider>(context);
    final isStudent = auth.user?.role == 'student';
    final showResources = isStudent;
    final effectiveTab =
        showResources ? _activeTab : _SidebarTab.agenda;

    return Container(
      color: scheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // + BUTTON (from your sketch)
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add, color: scheme.primary, size: 24),
                  tooltip: 'New post',
                  onPressed: () => _showQuickCreatePostDialog(context),
                ),
                const SizedBox(width: 8),
                Text(
                  'New Post',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: theme.dividerColor,
          ),
          if (showResources)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      context: context,
                      label: 'Agenda',
                      selected: effectiveTab == _SidebarTab.agenda,
                      onTap: () => setState(() => _activeTab = _SidebarTab.agenda),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTabButton(
                      context: context,
                      label: 'Resources',
                      selected: effectiveTab == _SidebarTab.resources,
                      onTap: () =>
                          setState(() => _activeTab = _SidebarTab.resources),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: effectiveTab == _SidebarTab.resources
                ? _buildResourcesSection(context)
                : _buildAgendaSection(context, channels),
          ),
          const _StudyBuddySection(),
          // USER PROFILE (bottom right)
          const _UserProfileCard(),
        ],
      ),
    );
  }

  Future<void> _showQuickCreatePostDialog(BuildContext context) async {
    final channels = Provider.of<ChannelsProvider>(context, listen: false);
    final channelId = channels.selectedChannelId;
    if (channelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a channel first.')),
      );
      return;
    }

    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    bool isProposal = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('New Post'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bodyController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Body',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isProposal,
                  title: const Text('Mark as proposal'),
                  onChanged: (value) =>
                      setStateDialog(() => isProposal = value ?? false),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final body = bodyController.text.trim();
                if (title.isEmpty || body.isEmpty) return;
                channels.createPost(
                  channelId: channelId,
                  title: title,
                  body: body,
                  isProposal: isProposal,
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabButton({
    required BuildContext context,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? scheme.primary : theme.dividerColor,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: selected ? scheme.primary : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgendaSection(BuildContext context, ChannelsProvider channels) {
    final theme = Theme.of(context);
    final agendaPosts = channels.agendaPosts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Agenda',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: agendaPosts.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'No agenda items yet.\nAdd posts from the center panel.',
                    style: theme.textTheme.bodySmall,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: agendaPosts.length,
                  itemBuilder: (context, index) {
                    final post = agendaPosts[index];
                    return _buildAgendaCard(
                      title: post.title,
                      color: post.isProposal ? Colors.orange : Colors.blue,
                      onRemove: () => channels.removePostFromAgenda(post.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildResourcesSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Resources',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _studentResources.length,
            itemBuilder: (context, index) {
              final resource = _studentResources[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.dividerColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resource.category,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resource.description,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static Widget _buildAgendaCard({
    required String title,
    required Color color,
    required VoidCallback onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: color, size: 18),
            tooltip: 'Remove from agenda',
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _StudyBuddySection extends StatelessWidget {
  const _StudyBuddySection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final currentUser = auth.user;
        if (currentUser == null || currentUser.role != 'student') {
          return const SizedBox.shrink();
        }

        final matches = auth.studyBuddyMatches;
        return Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: theme.dividerColor)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Peer Match',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (matches.isEmpty)
                Text(
                  'No close matches yet. Update your profile to improve matching.',
                  style: theme.textTheme.bodySmall,
                )
              else
                ...matches.take(3).map(
                      (match) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: scheme.primary.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${match.user.name} • ${match.user.pillar} • ${match.user.year}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              match.sharedInterests.isEmpty
                                  ? 'Match score: ${match.score}'
                                  : 'Shared: ${match.sharedInterests.join(', ')}',
                              style: theme.textTheme.bodySmall,
                            ),
                            if (match.sharedWorkEthics.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Ethics: ${match.sharedWorkEthics.join(', ')}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                            if (match.sharedValues.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Values: ${match.sharedValues.join(', ')}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                            const SizedBox(height: 8),
                            _buildSessionRequestAction(
                              context: context,
                              auth: auth,
                              matchUserId: match.user.id,
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSessionRequestAction({
    required BuildContext context,
    required AuthProvider auth,
    required String matchUserId,
  }) {
    final status = auth.getSessionRequestStatus(matchUserId);
    final scheme = Theme.of(context).colorScheme;

    if (status == 'pending') {
      return Row(
        children: [
          Icon(Icons.schedule, size: 16, color: Colors.orange.shade700),
          const SizedBox(width: 6),
          Text('Request pending', style: Theme.of(context).textTheme.bodySmall),
        ],
      );
    }
    if (status == 'accepted') {
      return Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
          const SizedBox(width: 6),
          Text('Session accepted', style: Theme.of(context).textTheme.bodySmall),
        ],
      );
    }
    if (status == 'declined') {
      return OutlinedButton.icon(
        onPressed: () => auth.sendSessionRequest(matchUserId),
        icon: Icon(Icons.refresh, size: 16, color: scheme.primary),
        label: const Text('Request again'),
      );
    }
    return ElevatedButton.icon(
      onPressed: auth.canSendSessionRequest(matchUserId)
          ? () => auth.sendSessionRequest(matchUserId)
          : null,
      icon: const Icon(Icons.send, size: 16),
      label: const Text('Request Session'),
    );
  }
}

class _UserProfileCard extends StatelessWidget {
  const _UserProfileCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.user == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    child: Text(
                      auth.user!.name.isNotEmpty
                          ? auth.user!.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: auth.isOnline ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.user!.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      auth.isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        color: auth.isOnline
                            ? Colors.green.shade700
                            : Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
