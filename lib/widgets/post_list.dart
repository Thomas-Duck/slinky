import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';

class PostList extends StatelessWidget {
  const PostList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelsProvider>(
      builder: (context, channels, child) {
        if (channels.selectedChannelId == null) {
          return Center(
            child: Text(
              'Select a channel',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          );
        }

        // Mock posts for demo
        final mockPosts = [
          {
            'id': '1',
            'title': 'FYP Proposal - Team A',
            'body': 'Need 3 members for AI project...',
            'isProposal': true,
          },
          {
            'id': '2',
            'title': 'Class Timetable Change',
            'body': 'Lab moved to Room B204...',
            'isProposal': false,
          },
          {
            'id': '3',
            'title': 'Project Partner Request',
            'body': 'Looking for ML expert...',
            'isProposal': true,
          },
        ];

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: mockPosts.length,
          itemBuilder: (context, index) {
            final post = mockPosts[index] as Map<String, dynamic>;
            final body = post['body'] as String;
            final bodyPreview =
                body.length > 50 ? '${body.substring(0, 50)}...' : body;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  post['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(bodyPreview),
                trailing: post['isProposal'] as bool
                    ? Chip(
                        label: Text(
                          'PROPOSAL',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: Colors.orange[100],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 0,
                        ),
                      )
                    : Icon(Icons.comment_outlined, color: Colors.grey[600]),
                onTap: () => channels.selectPost(post['id'] as String),
              ),
            );
          },
        );
      },
    );
  }
}
