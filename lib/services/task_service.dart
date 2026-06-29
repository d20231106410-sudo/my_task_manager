import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../task.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _tasksRef => _db.collection('tasks');

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }

  // ─── Add Task ───────────────────────────────────────────────
  Future<void> addTask(
    String title,
    String description, {
    DateTime? dueDate,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _tasksRef.add({
      'userID'      : user.uid,
      'title'       : title.trim(),
      'description' : description.trim(),
      'createdAt'   : FieldValue.serverTimestamp(), // ← fixed
      'dueDate'     : dueDate != null ? Timestamp.fromDate(dueDate) : null,
      'isDone'      : false,
      'status'      : 'Incomplete',
    });
  }

  // ─── Get Tasks (realtime stream) ────────────────────────────
  Stream<List<Task>> getUserTasks() {
    return _tasksRef
        .where('userID', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Task.fromFirestore(d))
            .toList());
  }

  // ─── Update Task ────────────────────────────────────────────
  Future<void> updateTask(
    String taskId,
    String title,
    String description, {
    DateTime? dueDate,
  }) async {
    await _tasksRef.doc(taskId).update({
      'title'       : title.trim(),
      'description' : description.trim(),
      'dueDate'     : dueDate != null ? Timestamp.fromDate(dueDate) : null,
    });
  }

  // ─── Toggle Done ────────────────────────────────────────────
  Future<void> toggleDone(String taskId, bool isDone) async {
    await _tasksRef.doc(taskId).update({
      'isDone': isDone,
      'status': isDone ? 'Done' : 'Incomplete',
    });
  }

  // ─── Update Status only ─────────────────────────────────────
  Future<void> updateStatus(String taskId, String status) async {
    await _tasksRef.doc(taskId).update({
      'status': status,
      'isDone': status == 'Done',
    });
  }

  // ─── Delete Task ────────────────────────────────────────────
  Future<void> deleteTask(String taskId) async {
    await _tasksRef.doc(taskId).delete();
  }

  // ─── Get Single Task ────────────────────────────────────────
  Future<Task?> getTask(String taskId) async {
    final doc = await _tasksRef.doc(taskId).get();
    if (!doc.exists) return null;
    return Task.fromFirestore(doc);
  }
}