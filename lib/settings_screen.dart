import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatelessWidget {
  final _auth = FirebaseAuth.instance;

  void _changePassword(BuildContext ctx) {
    final _pwdCtrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text('New Password'),
        content: TextField(
          controller: _pwdCtrl,
          decoration: InputDecoration(hintText: 'Enter new password'),
          obscureText: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          ElevatedButton(
            child: Text('Update'),
            onPressed: () async {
              final pw = _pwdCtrl.text.trim();
              if (pw.isNotEmpty) {
                await _auth.currentUser?.updatePassword(pw);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Password changed'))
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext ctx) async {
    await _auth.signOut();
    Navigator.of(ctx).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Change Password'),
            onTap: () => _changePassword(context),
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
