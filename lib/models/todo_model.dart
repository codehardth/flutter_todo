// constant สำหรับเก็บค่าระดับความสำคัญของ todo task
class ToDoPriority {
  const ToDoPriority._();

  static const low = 'Low';
  static const medium = 'Medium';
  static const high = 'High';

  static const List<String> allStatuses = [
    low,
    medium,
    high,
  ];
}

// constant สำหรับเก็บสถานะของ todo task
class ToDoStatus {
  const ToDoStatus._();

  static const pending = 'Pending';
  static const inprogress = 'InProgress';
  static const completed = 'Completed';

  static const List<String> allStatuses = [
    pending,
    inprogress,
    completed,
  ];
}

class TodoModel {
  String id;
  String title;
  String priority;
  String status;
  DateTime dueDate;
  String createdBy;
  DateTime? createdAt;
  String? updatedBy;
  DateTime? updatedAt;

  TodoModel({
    required this.id,
    required this.title,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  // Factory constructor สำหรับแปลง JSON เป็นออบเจ็กต์ของ TodoModel (Object) โดยการ แมปข้อมูล (map data) จาก JSON แต่ละฟิลด์ให้เข้ากับพารามิเตอร์ของ TodoModel
  // ถูกเรียกใช้เมื่อต้องการแมปข้อมูลจาก API มาเป็น TodoModel ที่ใช้ภายใน Application
  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      title: json['title'],
      priority: json['priority'],
      status: json['status'],
      dueDate: DateTime.parse(json['dueDate']),
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedBy: json['updatedBy'],
      updatedAt:
          json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt']),
    );
  }
}
