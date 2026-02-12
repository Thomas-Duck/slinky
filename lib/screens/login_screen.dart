import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import 'main_screen.dart';
import 'profile_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _showOtp = false;
  String _selectedRole = 'student';

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          final theme = Theme.of(context);
          final scheme = theme.colorScheme;
          if (auth.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school, size: 80, color: scheme.primary),
                const SizedBox(height: 20),
                Text(
                  'slinky',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'College Email (user@college.edu)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRole,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: 'student',
                          child: Text('I am a Student'),
                        ),
                        DropdownMenuItem(
                          value: 'staff',
                          child: Text('I am Staff'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedRole = value);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_showOtp)
                  TextField(
                    controller: _otpController,
                    decoration: InputDecoration(
                      labelText: 'Enter OTP',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                  ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    if (_showOtp) {
                      await Provider.of<AuthProvider>(context, listen: false)
                          .loginWithEmail(
                        _emailController.text,
                        _otpController.text,
                        selectedRole: _selectedRole,
                      );
                      if (context.mounted) {
                        final auth =
                            Provider.of<AuthProvider>(context, listen: false);
                        if (auth.isAuthenticated) {
                          Provider.of<ChannelsProvider>(context, listen: false)
                              .setUser(auth.user);
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => auth.requiresProfileSetup
                                    ? const ProfileSetupScreen(fromLogin: true)
                                    : const MainScreen(),
                              ),
                            );
                          }
                        }
                      }
                    } else {
                      setState(() => _showOtp = true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                  ),
                  child: Text(_showOtp ? 'Login' : 'Send OTP'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
