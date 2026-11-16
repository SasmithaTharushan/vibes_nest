import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:vibes_nest/constants.dart';
import 'package:vibes_nest/pages/crisis_help_page.dart';
import 'package:vibes_nest/pages/faq_page.dart';
import 'package:vibes_nest/pages/progress_tracker.dart';
import 'package:vibes_nest/pages/welcome_screen.dart';
import 'package:vibes_nest/services/local_profile.dart';
import 'package:vibes_nest/widgets/profile_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const _shareText =
      'I use Vibes Nest to look after my mental wellbeing. Check it out: '
      'https://github.com/SasmithaTharushan/vibes_nest';

  String _name = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final name = await LocalProfile.name();
    final email = await LocalProfile.email();
    if (mounted) {
      setState(() {
        _name = name;
        _email = email;
      });
    }
  }

  void _open(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  Future<void> _share() async {
    await Clipboard.setData(const ClipboardData(text: _shareText));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Link copied! Paste it to share Vibes Nest with a friend.')));
  }

  Future<void> _logOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You can sign back in at any time.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Log out')),
        ],
      ),
    );
    if (confirmed != true) return;
    await LocalProfile.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = _name.isNotEmpty ? _name[0].toUpperCase() : '?';
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Constants.primaryColor.withValues(alpha: .5),
                  width: 5.0,
                ),
              ),
              child: CircleAvatar(
                radius: 56,
                backgroundColor: Constants.primaryColor,
                child: Text(initial,
                    style: const TextStyle(fontSize: 40, color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _name,
            textAlign: TextAlign.center,
            style: TextStyle(color: Constants.blackColor, fontSize: 22),
          ),
          Text(
            _email,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Constants.blackColor.withValues(alpha: .4)),
          ),
          const SizedBox(height: 24),
          ProfileWidget(
            icon: Icons.bar_chart,
            title: 'My Progress',
            onTap: () => _open(const ProgressTrackerPage()),
          ),
          ProfileWidget(
            icon: Icons.help_outline,
            title: 'FAQs',
            onTap: () => _open(const FaqPage()),
          ),
          ProfileWidget(
            icon: Icons.share,
            title: 'Share Vibes Nest',
            onTap: _share,
          ),
          ProfileWidget(
            icon: Icons.phone_in_talk,
            title: 'Get help now',
            color: Colors.red.shade400,
            onTap: () => _open(const CrisisHelpPage()),
          ),
          ProfileWidget(
            icon: Icons.logout,
            title: 'Log Out',
            onTap: _logOut,
          ),
        ],
      ),
    );
  }
}
