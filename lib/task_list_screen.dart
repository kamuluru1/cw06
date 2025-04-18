import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'chat_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Hard‑coded boards for demo; you can later fetch these from Firestore too.
  final List<Board> _boards = [
    Board(id: 'general', name: 'General', icon: Icons.forum),
    Board(id: 'tech',    name: 'Tech',    icon: Icons.computer),
    Board(id: 'random',  name: 'Random',  icon: Icons.tag_faces),
  ];

  Future<void> _logout() async {
    await _auth.signOut();
    // after sign‐out, pop back to your login screen
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final userEmail = user?.email ?? 'No Email';

    return Scaffold(
      appBar: AppBar(
        title: Text('Message Boards'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),

      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.displayName ?? ''),
              accountEmail: Text(userEmail),
            ),
            ListTile(
              leading: Icon(Icons.forum),
              title: Text('Message Boards'),
              onTap: () {
                Navigator.pop(context); // just close drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ProfileScreen())
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => SettingsScreen())
                );
              },
            ),
          ],
        ),
      ),

      body: ListView.builder(
        itemCount: _boards.length,
        itemBuilder: (ctx, i) {
          final b = _boards[i];
          return ListTile(
            leading: Icon(b.icon),
            title: Text(b.name),
            onTap: () {
              Navigator.push(context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    boardId: b.id,
                    boardName: b.name,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class Board {
  final String id;
  final String name;
  final IconData icon;
  Board({required this.id, required this.name, required this.icon});
}
