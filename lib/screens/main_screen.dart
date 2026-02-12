import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../widgets/channel_list.dart';
import '../widgets/post_list.dart';
import '../widgets/post_detail.dart';
import '../widgets/quick_actions.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = Provider.of<AuthProvider>(context);
    final channels = Provider.of<ChannelsProvider>(context, listen: false);
    if (auth.user != null && channels.user != auth.user) {
      channels.setUser(auth.user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Campus Comm',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              Provider.of<ChannelsProvider>(context, listen: false).setUser(null);
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // LEFT: Channel List (from your sketch)
          Container(
            width: 250,
            color: Colors.grey[50],
            child: const ChannelList(),
          ),

          // CENTER: Posts + Detail (Main Board from sketch)
          Expanded(
            child: Column(
              children: [
                Expanded(child: PostList()),
                Container(height: 1, color: Colors.grey[300]!),
                SizedBox(height: 250, child: PostDetail()),
              ],
            ),
          ),

          // RIGHT: Quick Actions Sidebar (from your sketch)
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Colors.grey[300]!)),
            ),
            child: const QuickActions(),
          ),
        ],
      ),
    );
  }
}
