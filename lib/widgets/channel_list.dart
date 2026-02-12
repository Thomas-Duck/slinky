import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../models/models.dart';

class ChannelList extends StatefulWidget {
  const ChannelList({super.key});

  @override
  State<ChannelList> createState() => _ChannelListState();
}

class _ChannelListState extends State<ChannelList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChannelsProvider>(context, listen: false).loadMockChannels();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Consumer<ChannelsProvider>(
      builder: (context, channels, child) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Channels',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.add, size: 20, color: scheme.primary),
                    tooltip: 'Create channel',
                    onPressed: () => _showCreateChannelDialog(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: channels.visibleChannels.length,
                itemBuilder: (context, index) {
                  final channel = channels.visibleChannels[index];
                  final isSelected = channels.selectedChannelId == channel.id;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? scheme.primary.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: scheme.primary.withValues(alpha: 0.2),
                        child: Text(
                          channel.name[0],
                          style: TextStyle(color: scheme.primary),
                        ),
                      ),
                      title: Text(
                        channel.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        channels.canManageStudentVisibility(channel)
                            ? '${channel.department} • L${channel.clearance} • ${channels.isChannelVisibleToStudents(channel.id) ? "Student visible" : "Hidden from students"}'
                            : '${channel.department} • L${channel.clearance}',
                        style:
                            theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                      ),
                      trailing: _buildTrailing(context, channel, channels),
                      onTap: () => channels.selectChannel(channel.id),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget? _buildTrailing(
      BuildContext context, Channel channel, ChannelsProvider channels) {
    final scheme = Theme.of(context).colorScheme;
    final canToggle = channels.canManageStudentVisibility(channel);
    final canPost = channels.userCanPostIn(channel);

    if (!canToggle && !canPost) return null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (canToggle)
          Tooltip(
            message: channels.isChannelVisibleToStudents(channel.id)
                ? 'Visible to students (tap to hide)'
                : 'Hidden from students (tap to show)',
            child: IconButton(
              iconSize: 20,
              splashRadius: 20,
              onPressed: () => channels.setChannelVisibleToStudents(
                channel.id,
                !channels.isChannelVisibleToStudents(channel.id),
              ),
              icon: Icon(
                channels.isChannelVisibleToStudents(channel.id)
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: channels.isChannelVisibleToStudents(channel.id)
                    ? scheme.primary
                    : Colors.grey[600],
              ),
            ),
          ),
        if (canPost)
          IconButton(
            iconSize: 20,
            splashRadius: 20,
            tooltip: 'Create post in channel',
            onPressed: () => _showCreatePostDialog(context, channel.id),
            icon: const Icon(Icons.add, color: Colors.green, size: 20),
          ),
      ],
    );
  }

  Future<void> _showCreateChannelDialog(BuildContext context) async {
    final channels = Provider.of<ChannelsProvider>(context, listen: false);
    if (!channels.canCurrentUserCreateChannels) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only staff/HOD/admin can create channels.')),
      );
      return;
    }

    final nameController = TextEditingController();
    final deptController = TextEditingController(text: 'CS');
    int selectedClearance = 1;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Create Channel'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Channel name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: deptController,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: selectedClearance,
                  decoration: const InputDecoration(
                    labelText: 'Clearance level',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('L1 (Students)')),
                    DropdownMenuItem(value: 2, child: Text('L2 (Staff)')),
                    DropdownMenuItem(value: 3, child: Text('L3 (HOD)')),
                    DropdownMenuItem(value: 4, child: Text('L4 (Admin)')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setStateDialog(() => selectedClearance = value);
                    }
                  },
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
                final name = nameController.text.trim();
                final dept = deptController.text.trim();
                if (name.isEmpty || dept.isEmpty) return;
                channels.createChannel(
                  name: name,
                  department: dept,
                  clearance: selectedClearance,
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCreatePostDialog(
      BuildContext context, String channelId) async {
    final channels = Provider.of<ChannelsProvider>(context, listen: false);
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    bool isProposal = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Create Post'),
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
}
