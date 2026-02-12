import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';

class PostList extends StatelessWidget {
  const PostList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Consumer<ChannelsProvider>(
      builder: (context, channels, child) {
        if (channels.selectedChannelId == null) {
          return Center(
            child: Text(
              'Select a channel',
              style: theme.textTheme.titleMedium,
            ),
          );
        }

        final posts = channels.postsForSelectedChannel;
        if (posts.isEmpty) {
          return Center(
            child: Text(
              'No posts in this channel',
              style: theme.textTheme.bodyMedium,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            final body = post.body;
            final bodyPreview =
                body.length > 50 ? '${body.substring(0, 50)}...' : body;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  post.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(bodyPreview),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (post.isProposal)
                      Chip(
                        label: Text(
                          'PROPOSAL',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: Colors.orange.withValues(alpha: 0.18),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 0,
                        ),
                      )
                    else
                      Icon(Icons.comment_outlined, color: theme.iconTheme.color),
                    IconButton(
                      tooltip: channels.isPostInAgenda(post.id)
                          ? 'Remove from agenda'
                          : 'Add to agenda',
                      onPressed: () => channels.togglePostInAgenda(post.id),
                      icon: Icon(
                        channels.isPostInAgenda(post.id)
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: channels.isPostInAgenda(post.id)
                            ? Colors.blue[700]
                            : scheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                onTap: () => channels.selectPost(post.id),
              ),
            );
          },
        );
      },
    );
  }
}
