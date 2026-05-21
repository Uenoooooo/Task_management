class TaskModel {
  final int? id;
  final int userId;
  final String title;
  final String description;
  final String status;
  final String category;
  final String createdDate;
  final String dueDate; 

  TaskModel({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.status = 'pending',
    required this.category,
    required this.createdDate,
    required this.dueDate, 
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id, 'user_id': userId, 'title': title,
      'description': description, 'status': status,
      'category': category, 'created_date': createdDate,
      'due_date': dueDate, 
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      description: map['description'],
      status: map['status'],
      category: map['category'],
      createdDate: map['created_date'],
      dueDate: map['due_date'] ?? '', 
    );
  }
}
