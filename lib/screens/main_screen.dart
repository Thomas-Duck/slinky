import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../widgets/channel_list.dart';
import '../widgets/post_list.dart';
import '../widgets/post_detail.dart';
import '../widgets/quick_actions.dart';
import 'login_screen.dart';
import 'profile_setup_screen.dart';

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
    final settings = Provider.of<AppSettingsProvider>(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'slinky',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: scheme.onPrimary,
          ),
        ),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            icon: const Icon(Icons.manage_accounts),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileSetupScreen(fromLogin: false),
                ),
              );
            },
          ),
          IconButton(
            tooltip: settings.isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
            icon: Icon(settings.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: settings.toggleThemeMode,
          ),
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
            color: scheme.surface,
            child: const ChannelList(),
          ),

          // CENTER: Posts + Detail (Main Board from sketch)
          Expanded(
            child: Column(
              children: [
                Expanded(child: PostList()),
                Container(height: 1, color: theme.dividerColor),
                SizedBox(height: 250, child: PostDetail()),
              ],
            ),
          ),

          // RIGHT: Quick Actions Sidebar (from your sketch)
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border(left: BorderSide(color: theme.dividerColor)),
            ),
            child: const QuickActions(),
          ),
        ],
      ),
    );
  }
}
