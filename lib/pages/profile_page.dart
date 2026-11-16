import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibes_nest/constants.dart';
import 'package:vibes_nest/pages/crisis_help_page.dart';
import 'package:vibes_nest/pages/faq_page.dart';
import 'package:vibes_nest/pages/progress_tracker.dart';
import 'package:vibes_nest/services/app_services.dart';
import 'package:vibes_nest/services/auth_service.dart';
import 'package:vibes_nest/widgets/profile_widget.dart';
import 'package:vibes_nest/widgets/text_prompt_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const _shareText =
      'I use Vibes Nest to look after my mental wellbeing. Check it out: '
      'https://github.com/SasmithaTharushan/vibes_nest';
  static const _privacyUrl =
      'https://github.com/SasmithaTharushan/vibes_nest/blob/main/PRIVACY.md';

  AuthService get _auth => AppServices.auth(context);

  void _open(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  void _toast(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _share() async {
    await Clipboard.setData(const ClipboardData(text: _shareText));
    if (mounted) _toast('Link copied! Paste it to share Vibes Nest with a friend.');
  }

  Future<void> _editName() async {
    final name = await showTextPrompt(
      context,
      title: 'Your name',
      confirmLabel: 'Save',
      hint: 'Full name',
      initialValue: _auth.displayName,
      capitalization: TextCapitalization.words,
    );
    if (name == null || name.isEmpty || !mounted) return;
    try {
      await _auth.updateName(name);
      if (mounted) setState(() {});
    } on AuthFailure catch (e) {
      if (mounted) _toast(e.message);
    }
  }

  Future<void> _resendVerification() async {
    await _auth.currentUser?.sendEmailVerification();
    if (mounted) _toast('Verification email sent. Check your inbox.');
  }

  Future<void> _logOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Your data stays safe in your account.'),
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
    if (confirmed != true || !mounted) return;
    // Pop first so the AuthGate (bottom of the stack) shows Welcome.
    final auth = _auth;
    Navigator.of(context).popUntil((route) => route.isFirst);
    await auth.signOut();
  }

  Future<void> _deleteAccount() async {
    final password = await showTextPrompt(
      context,
      title: 'Delete account?',
      message: 'This permanently deletes your account and all your moods, '
          'sleep logs, journal notes, tasks, chats, garden and community '
          'posts. This cannot be undone.',
      label: 'Enter your password to confirm',
      obscure: true,
      destructive: true,
      confirmLabel: 'Delete forever',
    );
    if (password == null || password.isEmpty || !mounted) return;
    final auth = _auth;
    final navigator = Navigator.of(context);
    try {
      await auth.deleteAccount(password: password);
      navigator.popUntil((route) => route.isFirst);
    } on AuthFailure catch (e) {
      if (mounted) _toast(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final name = _auth.displayName;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final verified = user?.emailVerified ?? false;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Constants.blackColor, fontSize: 22)),
              ),
              IconButton(
                tooltip: 'Edit name',
                icon: const Icon(Icons.edit, size: 18),
                onPressed: _editName,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(user?.email ?? '',
                  style: TextStyle(
                      color: Constants.blackColor.withValues(alpha: .5))),
              const SizedBox(width: 6),
              Icon(verified ? Icons.verified : Icons.error_outline,
                  size: 16, color: verified ? Colors.green : Colors.orange),
            ],
          ),
          if (!verified)
            Center(
              child: TextButton(
                onPressed: _resendVerification,
                child: const Text('Email not verified · Resend link'),
              ),
            ),
          const SizedBox(height: 16),
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
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy policy',
            onTap: () => launchUrl(Uri.parse(_privacyUrl),
                mode: LaunchMode.externalApplication),
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
          const Divider(height: 32),
          ProfileWidget(
            icon: Icons.delete_forever,
            title: 'Delete account',
            color: Colors.red,
            onTap: _deleteAccount,
          ),
        ],
      ),
    );
  }
}
