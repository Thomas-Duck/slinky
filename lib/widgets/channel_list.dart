import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';

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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.add, size: 20, color: Colors.blue[700]),
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
                      color: isSelected ? Colors.blue[50] : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: Text(
                          channel.name[0],
                          style: TextStyle(color: Colors.blue[800]),
                        ),
                      ),
                      title: Text(
                        channel.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        '${channel.department} • L${channel.clearance}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      trailing: channels.userCanPostIn(channel)
                          ? Icon(Icons.add, color: Colors.green[700], size: 20)
                          : null,
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
}
