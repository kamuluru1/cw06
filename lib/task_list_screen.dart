import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

// Optional Task model to encapsulate task details.
class Task {
  String id;
  String name;
  bool isCompleted;
  List<Map<String, dynamic>> subTasks;

  Task({
    required this.id,
    required this.name,
    required this.isCompleted,
    required this.subTasks,
  });
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Optionally scope tasks to the current user
  String get userId => _auth.currentUser?.uid ?? 'anonymous';

  // Reference to the tasks collection.
  CollectionReference get tasksRef => _firestore.collection('tasks');

  /// Adds a new task to Firebase with example nested sub-tasks.
  Future<void> _addTask() async {
    String taskName = _taskController.text.trim();
    if (taskName.isNotEmpty) {
      await tasksRef.add({
        'userId': userId,
        'name': taskName,
        'isCompleted': false,
        // Example sub-tasks; these can be expanded or made dynamic.
        'subTasks': [
          {'timeFrame': '9 am - 10 am', 'details': 'HW1, Essay2'},
          {'timeFrame': '12 pm - 2 pm', 'details': 'Group meeting'},
        ],
      });
      _taskController.clear();
    }
  }

  /// Toggles the completion status of a task.
  Future<void> _toggleTask(String id, bool currentStatus) async {
    await tasksRef.doc(id).update({'isCompleted': !currentStatus});
  }

  /// Deletes a task from Firebase.
  Future<void> _deleteTask(String id) async {
    await tasksRef.doc(id).delete();
  }

  /// Logs the user out.
  Future<void> _logout() async {
    await _auth.signOut();
  }

  /// Builds the widget for each task item, including an ExpansionTile for sub-tasks.
  Widget _buildTaskItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Filter tasks by user if desired.
    if (data['userId'] != userId) {
      return Container();
    }
    final task = Task(
      id: doc.id,
      name: data['name'],
      isCompleted: data['isCompleted'],
      subTasks: List<Map<String, dynamic>>.from(data['subTasks'] ?? []),
    );
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) => _toggleTask(task.id, task.isCompleted),
        ),
        title: Text(
          task.name,
          style: TextStyle(
            decoration:
            task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () => _deleteTask(task.id),
        ),
        // Display nested sub-tasks if available.
        subtitle: task.subTasks.isNotEmpty
            ? ExpansionTile(
          title: Text('View Sub-Tasks'),
          children: task.subTasks.map((subTask) {
            return ListTile(
              title: Text(
                  '${subTask['timeFrame']}: ${subTask['details']}'),
            );
          }).toList(),
        )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Manager"),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          // Input field and "Add" button.
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      labelText: 'Enter task',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTask,
                  child: Text("Add"),
                ),
              ],
            ),
          ),
          // Real-time task list from Firestore.
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: tasksRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                return ListView(
                  children: docs.map((doc) => _buildTaskItem(doc)).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
