import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? dueDate;   
  final bool isDone;         
  final String userId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.dueDate,
    this.isDone = false,
    required this.userId,
  });

  bool get isOverdue {
    if (isDone || dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isUrgent {
    if (isDone || dueDate == null) return false;
    final diff = dueDate!.difference(DateTime.now());
    return diff.inHours <= 24 && diff.inSeconds > 0;
  }

  String get label {
    if (isDone) return 'Done';
    if (isOverdue) return 'Overdue';
    if (isUrgent) return 'Urgent';
    return 'Incomplete';
  }

  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      isDone: data['isDone'] ?? false,
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'isDone': isDone,
      'userId': userId,
    };
  }
}
