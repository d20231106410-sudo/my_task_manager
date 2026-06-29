import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../task.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../widgets/widget.dart';
import '../theme.dart';
import '../screens/add_task.dart';
import '../screens/edit_task.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _auth = AuthService();
  final _taskService = TaskService();
  String _filter = 'All';

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to log out?',
            style: TextStyle(color: AppTheme.textMid)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: TextStyle(color: AppTheme.textMid))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _auth.logout();
  }

  Future<void> _confirmDelete(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(Icons.warning_amber_rounded, color: AppTheme.danger, size: 24),
          const SizedBox(width: 8),
          const Text('Delete Task',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        ]),
        content: Text('Delete "${task.title}"? This cannot be undone.',
            style: TextStyle(color: AppTheme.textMid, fontSize: 14)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: TextStyle(color: AppTheme.textMid))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _taskService.deleteTask(task.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Task deleted'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  List<Task> _applyFilter(List<Task> tasks) {
    switch (_filter) {
      case 'Done':       return tasks.where((t) => t.isDone).toList();
      case 'Incomplete': return tasks.where((t) => !t.isDone && !t.isOverdue && !t.isUrgent).toList();
      case 'Urgent':     return tasks.where((t) => t.isUrgent).toList();
      case 'Overdue':    return tasks.where((t) => t.isOverdue).toList();
      default:           return tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _auth.displayName;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha:0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Avatar with first letter of name
                      Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.primary, AppTheme.primaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Greeting with name
                            Text(
                              'Hello ${_capitalize(name)}! 👋',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDark,
                                  fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Manage your tasks here, do not miss the date yah! ',
                              style: TextStyle(
                                  color: AppTheme.textMid, fontSize: 11),
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
                  const SizedBox(height: 16),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Incomplete', 'Done', 'Urgent', 'Overdue']
                          .map((f) => _FilterChip(
                                label: f,
                                selected: _filter == f,
                                onTap: () => setState(() => _filter = f),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: StreamBuilder<List<Task>>(
                stream: _taskService.getUserTasks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(color: AppTheme.primary));
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: ErrorBanner(
                            message: 'Error loading tasks. Please try again.'),
                      ),
                    );
                  }

                  final all = snapshot.data ?? [];
                  final tasks = _applyFilter(all);

                  if (tasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 90, height: 90,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha:0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.task_alt_rounded,
                                size: 42, color: AppTheme.primary),
                          ),
                          const SizedBox(height: 20),
                          Text('No $_filter tasks',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: AppTheme.textDark)),
                          const SizedBox(height: 8),
                          Text(
                            _filter == 'All'
                                ? 'Tap + to add your first task'
                                : 'No tasks with this status',
                            style: TextStyle(
                                color: AppTheme.textMid, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Summary row
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                        child: Row(
                          children: [
                            _SummaryPill(
                                label: '${all.length} Total',
                                color: AppTheme.primary),
                            const SizedBox(width: 8),
                            _SummaryPill(
                                label: '${all.where((t) => t.isDone).length} Done',
                                color: AppTheme.success),
                            const SizedBox(width: 8),
                            _SummaryPill(
                                label: '${all.where((t) => t.isUrgent).length} Urgent',
                                color: AppTheme.warning),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                          itemCount: tasks.length,
                          itemBuilder: (context, i) {
                            return _TaskCard(
                              task: tasks[i],
                              onEdit: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        EditTaskScreen(task: tasks[i])),
                              ),
                              onToggleDone: () => _taskService.toggleDone(
                                  tasks[i].id, !tasks[i].isDone),
                              onDelete: () => _confirmDelete(tasks[i]),
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
            context, MaterialPageRoute(builder: (_) => const AddTaskScreen())),
        backgroundColor: AppTheme.success,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task',
            style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 6,
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onToggleDone;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.onEdit,
    required this.onToggleDone,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dueFmt = task.dueDate != null
        ? DateFormat('dd MMM yyyy').format(task.dueDate!)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: _borderColor(), width: 4)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onToggleDone,
                  child: Container(
                    width: 26, height: 26,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: task.isDone ? AppTheme.success : Colors.transparent,
                      border: Border.all(
                        color: task.isDone ? AppTheme.success : AppTheme.textLight,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: task.isDone
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: task.isDone ? AppTheme.textMid : AppTheme.textDark,
                          decoration: task.isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      StatusLabel(label: task.label),
                    ],
                  ),
                ),

                IconButton(
                  icon: Icon(Icons.edit_outlined,
                      color: AppTheme.success, size: 20),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Edit',
                ),
                const SizedBox(width: 8),

                // Delete button (red)
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded,
                      color: AppTheme.danger, size: 20),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Delete',
                ),
              ],
            ),

            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 38),
                child: Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppTheme.textMid, fontSize: 13, height: 1.4),
                ),
              ),
            ],

            if (dueFmt != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 38),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 12,
                        color: task.isOverdue ? AppTheme.overdue : AppTheme.textMid),
                    const SizedBox(width: 4),
                    Text(
                      'Due $dueFmt',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: task.isOverdue ? AppTheme.overdue : AppTheme.textMid,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _borderColor() {
    if (task.isDone) return AppTheme.success;
    if (task.isOverdue) return AppTheme.overdue;
    if (task.isUrgent) return AppTheme.warning;
    return AppTheme.incomplete;
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  Color get _color {
    switch (label) {
      case 'Done':    return AppTheme.success;
      case 'Urgent':  return AppTheme.warning;
      case 'Overdue': return AppTheme.overdue;
      default:        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? _color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? _color : AppTheme.textLight, width: 1.5),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppTheme.textMid,
            )),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final Color color;
  const _SummaryPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}