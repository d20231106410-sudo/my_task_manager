import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../task.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _tasksRef => _db.collection('tasks');

  String get _uid => _auth.currentUser!.uid;


  Future<void> addTask(String title, String description) async {
    final task = Task(
      id: '',
      title: title.trim(),
      description: description.trim(),
      createdAt: DateTime.now(),
      userId: _uid,
    );
    await _tasksRef.add(task.toMap());
  }

  Stream<List<Task>> getUserTasks() {
    return _tasksRef
        .where('userId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  Future<void> updateTask(String taskId, String title, String description) async {
    await _tasksRef.doc(taskId).update({
      'title': title.trim(),
      'description': description.trim(),
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksRef.doc(taskId).delete();
  }
}
