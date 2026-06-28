import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../task.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../theme.dart';
import '../widget.dart';
import 'add_task.dart';
import 'edit_task.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _auth = AuthService();
  final _taskService = TaskService();

  Future<void> _confirmDelete(BuildContext context, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.danger, size: 24),
            SizedBox(width: 10),
            Text('Delete Task',
                style:
                    TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
          style: TextStyle(color: AppTheme.textMid, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(color: AppTheme.textMid)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _taskService.deleteTask(task.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task deleted'),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to log out?',
            style: TextStyle(color: AppTheme.textMid)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textMid)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _auth.logout();
  }

  String _formatDate(DateTime dt) {
    return DateFormat('MMM d, y · h:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final email = _auth.currentUser?.email ?? '';
    final firstName = email.split('@').first;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 20),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.04),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primary, AppTheme.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        firstName.isNotEmpty
                            ? firstName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hey, $firstName! 👋',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Manage your tasks below',
                          style: TextStyle(
                              color: AppTheme.textMid, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.logout_rounded, color: AppTheme.textMid),
                    onPressed: _confirmLogout,
                    tooltip: 'Logout',
                  ),
                ],
              ),
            ),

            // Task List
            Expanded(
              child: StreamBuilder<List<Task>>(
                stream: _taskService.getUserTasks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: ErrorBanner(
                            message: 'Error loading tasks. Please try again.'),
                      ),
                    );
                  }

                  final tasks = snapshot.data ?? [];

                  if (tasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha:0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.task_alt_rounded,
                              size: 42,
                              color: AppTheme.primary,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'No tasks yet',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: AppTheme.textDark,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap the + button to add your first task',
                            style: TextStyle(
                                color: AppTheme.textMid, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Task count pill
                      Padding(
                        padding: EdgeInsets.fromLTRB(24, 16, 24, 4),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha:0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${tasks.length} task${tasks.length != 1 ? 's' : ''}',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(24, 12, 24, 100),
                          itemCount: tasks.length,
                          itemBuilder: (context, i) {
                            final task = tasks[i];
                            return TaskCard(
                              title: task.title,
                              description: task.description,
                              date: _formatDate(task.createdAt),
                              colorIndex: i,
                              onEdit: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => EditTaskScreen(task: task)),
                              ),
                              onDelete: () => _confirmDelete(context, task),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddTaskScreen()),
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add_rounded),
        label: Text(
          'Add Task',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 6,
      ),
    );
  }
}
