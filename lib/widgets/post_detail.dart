import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../models/models.dart';

class PostDetail extends StatefulWidget {
  const PostDetail({super.key});

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  final _chatController = TextEditingController();
  String? _proposalResponse; // null = not answered, 'accepted' or 'rejected'
  String? _lastPostId;

  Future<void> _handlePostMenuAction(
    BuildContext context, {
    required String action,
    required ChannelsProvider channels,
    required Post? selectedPost,
  }) async {
    if (selectedPost == null) return;
    if (action == 'toggle_agenda') {
      channels.togglePostInAgenda(selectedPost.id);
      return;
    }
    if (action == 'copy_post') {
      await Clipboard.setData(
        ClipboardData(text: '${selectedPost.title}\n\n${selectedPost.body}'),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post copied to clipboard')),
      );
      return;
    }
    if (action == 'refresh_feedback') {
      await channels.loadFeedbackForPost(selectedPost.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback refreshed')),
      );
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Consumer2<AuthProvider, ChannelsProvider>(
      builder: (context, auth, channels, child) {
        final hasSelectedPost = channels.selectedPostId != null;
        final selectedPost = channels.selectedPost;
        final isProposal = selectedPost?.isProposal ?? false;

        if (_lastPostId != channels.selectedPostId) {
          _lastPostId = channels.selectedPostId;
          _proposalResponse = null;
          if (selectedPost != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                channels.loadFeedbackForPost(selectedPost.id);
              }
            });
          }
        }

        return Column(
          children: [
            // MAIN BOARD HEADER (from your sketch)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(bottom: BorderSide(color: theme.dividerColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasSelectedPost
                              ? (selectedPost?.title ?? 'Post')
                              : 'Select a post',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          hasSelectedPost
                              ? 'Roles: ${selectedPost?.authorRole.toUpperCase() ?? "N/A"}'
                              : '',
                          style: theme.textTheme.bodyMedium,
                        ),
                        if (hasSelectedPost &&
                            channels.selectedPostId != null &&
                            channels.isCurrentUserPostAuthor(
                                channels.selectedPostId!)) ...[
                          const SizedBox(height: 6),
                          Text(
                            '${channels.getPostViewCount(channels.selectedPostId!)} views / ${channels.totalAppUsers} users',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Post actions',
                    icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
                    onSelected: (value) => _handlePostMenuAction(
                      context,
                      action: value,
                      channels: channels,
                      selectedPost: selectedPost,
                    ),
                    itemBuilder: (context) {
                      if (selectedPost == null) {
                        return const [
                          PopupMenuItem<String>(
                            enabled: false,
                            value: 'none',
                            child: Text('No post selected'),
                          ),
                        ];
                      }
                      return [
                        PopupMenuItem<String>(
                          value: 'toggle_agenda',
                          child: Text(
                            channels.isPostInAgenda(selectedPost.id)
                                ? 'Remove from agenda'
                                : 'Add to agenda',
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'copy_post',
                          child: Text('Copy post text'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'refresh_feedback',
                          child: Text('Refresh feedback'),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ),

            // POST BODY + CONSENT + FEEDBACK
            Expanded(
              child: hasSelectedPost
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedPost?.body ?? '',
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (selectedPost != null)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    channels.togglePostInAgenda(selectedPost.id),
                                icon: Icon(
                                  channels.isPostInAgenda(selectedPost.id)
                                      ? Icons.bookmark_remove
                                      : Icons.bookmark_add,
                                ),
                                label: Text(
                                  channels.isPostInAgenda(selectedPost.id)
                                      ? 'Remove from agenda'
                                      : 'Add to agenda',
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),

                          // CONSENT/REJECT BUTTONS (from your sketch)
                          if (isProposal)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.orange.withValues(alpha: 0.6)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your Response Required',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (_proposalResponse == null)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => setState(() {
                                            _proposalResponse = 'accepted';
                                          }),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('ACCEPT'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => setState(() {
                                            _proposalResponse = 'rejected';
                                          }),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('REJECT'),
                                        ),
                                      ],
                                    )
                                  else
                                    Text(
                                      _proposalResponse!.toUpperCase(),
                                      style: TextStyle(
                                        color: _proposalResponse == 'accepted'
                                            ? Colors.green[700]
                                            : Colors.red[700],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                ],
                              ),
                            ),

                          // FEEDBACK (integrated under each post)
                          const SizedBox(height: 20),
                          Text(
                            'Feedback',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            constraints: const BoxConstraints(minHeight: 80),
                            decoration: BoxDecoration(
                              color: scheme.surface.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: StreamBuilder<List<PostFeedback>>(
                              stream: selectedPost == null
                                  ? const Stream.empty()
                                  : channels.watchFeedback(selectedPost.id),
                              initialData: selectedPost == null
                                  ? const []
                                  : channels.getFeedbackForPost(selectedPost.id),
                              builder: (context, snapshot) {
                                final feedbackItems = snapshot.data ?? const [];
                                if (feedbackItems.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      'No feedback yet. Be the first to post.',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  );
                                }
                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: feedbackItems.length,
                                  padding: const EdgeInsets.all(12),
                                  itemBuilder: (context, index) {
                                    final item = feedbackItems[index];
                                    return ListTile(
                                      leading: Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: scheme.primary
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.person_outline,
                                          size: 18,
                                          color: scheme.primary,
                                        ),
                                      ),
                                      title: Text('${item.authorName}: ${item.text}'),
                                      subtitle: Text(
                                        _formatRelativeTime(item.createdAt),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.textTheme.bodySmall?.color,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _chatController,
                                  decoration: InputDecoration(
                                    hintText: 'Add feedback...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(Icons.send, color: scheme.primary),
                                onPressed: () async {
                                  if (_chatController.text.trim().isNotEmpty &&
                                      selectedPost != null &&
                                      auth.user != null) {
                                    final text = _chatController.text.trim();
                                    _chatController.clear();
                                    await channels.addFeedback(
                                      selectedPost.id,
                                      text,
                                      author: auth.user!,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Text(
                        'Select a post to view details',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  String _formatRelativeTime(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }
}
