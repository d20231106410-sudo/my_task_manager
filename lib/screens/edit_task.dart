import 'package:flutter/material.dart';
import '../task.dart';
import '../services/task_service.dart';
import '../theme.dart';
import '../widgets/widget.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;
  const EditTaskScreen({super.key, required this.task});
  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  final _taskService = TaskService();
  DateTime? _dueDate;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task.title);
    _descCtrl = TextEditingController(text: widget.task.description);
    _dueDate = widget.task.dueDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _updateTask() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await _taskService.updateTask(
          widget.task.id, _titleCtrl.text, _descCtrl.text,
          dueDate: _dueDate);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Failed to update task. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit Task',
            style: TextStyle(
                color: AppTheme.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 18)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      const Color(0xFF1565C0).withValues(alpha:0.1),
                      const Color(0xFF1E88E5).withValues(alpha:0.08),
                    ]),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.edit_note_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Edit task details',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark,
                                  fontSize: 15)),
                          Text('Update the information below',
                              style: TextStyle(
                                  color: AppTheme.textMid, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (_error != null) ...[
                  ErrorBanner(message: _error!),
                  const SizedBox(height: 16),
                ],

                Text('Task Title',
                    style: TextStyle(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'Task title'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Title is required'
                      : null,
                ),
                const SizedBox(height: 20),

                Text('Description',
                    style: TextStyle(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration:
                      const InputDecoration(hintText: 'Task description'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Description is required'
                      : null,
                ),
                const SizedBox(height: 20),

                Text('Due Date (optional)',
                    style: TextStyle(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDueDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            color: AppTheme.primary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _dueDate != null
                                ? 'Due: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                                : 'Select a due date',
                            style: TextStyle(
                              color: _dueDate != null
                                  ? AppTheme.textDark
                                  : AppTheme.textLight,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (_dueDate != null)
                          GestureDetector(
                            onTap: () => setState(() => _dueDate = null),
                            child: Icon(Icons.close_rounded,
                                color: AppTheme.textMid, size: 18),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                GradientButton(
                  label: 'Save Changes',
                  icon: Icons.save_rounded,
                  onPressed: _updateTask,
                  isLoading: _loading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
