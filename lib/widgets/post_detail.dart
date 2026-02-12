import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';

class PostDetail extends StatefulWidget {
  const PostDetail({super.key});

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  final _chatController = TextEditingController();
  String? _proposalResponse; // null = not answered, 'accepted' or 'rejected'

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChannelsProvider>(
      builder: (context, channels, child) {
        final hasSelectedPost = channels.selectedPostId != null;
        const isProposal = true; // Demo post is a proposal

        return Column(
          children: [
            // MAIN BOARD HEADER (from your sketch)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasSelectedPost
                              ? 'FYP Proposal - Team A'
                              : 'Select a post',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          hasSelectedPost
                              ? 'Roles: Student-Y2, Staff-CS'
                              : '',
                          style: TextStyle(color: Colors.grey[600]),
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
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(Icons.more_vert, color: Colors.grey[600]),
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
                            'Need 3 members for AI/ML project. Skills required: '
                            'Python, TensorFlow. Meetings: Tue/Thu 2pm.',
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // CONSENT/REJECT BUTTONS (from your sketch)
                          if (isProposal)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your Response Required',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[900],
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

                          // COMMENTS (integrated under each post)
                          const SizedBox(height: 20),
                          Text(
                            'Comments',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            constraints: const BoxConstraints(minHeight: 80),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView(
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(12),
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue[100],
                                    child: Text(
                                      'J',
                                      style: TextStyle(color: Colors.blue[800]),
                                    ),
                                  ),
                                  title: const Text('John: Great project idea!'),
                                  subtitle: Text(
                                    '2 min ago',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.reply,
                                    size: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _chatController,
                                  decoration: InputDecoration(
                                    hintText: 'Add a comment...',
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
                                icon: Icon(Icons.send, color: Colors.blue[700]),
                                onPressed: () {
                                  if (_chatController.text.isNotEmpty) {
                                    setState(() {
                                      _chatController.clear();
                                    });
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
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
