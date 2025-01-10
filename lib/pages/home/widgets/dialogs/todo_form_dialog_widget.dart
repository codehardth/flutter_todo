import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/todo_model.dart';

// dialog widget สำหรับสร้างหรือแก้ไขข้อมูล todo
// เป็น StatefulWidget เพราะต้องการให้ UI เปลี่ยนแปลงเมื่อมีการอัปเดตข้อมูล
// รับพารามิเตอร์ผ่าน constructor:
//  - isEdit: บอกว่ากำลังอยู่ในโหมด "แก้ไข" (true) หรือ "เพิ่มใหม่" (false)
//  - initialTitle, initialPriority, initialStatus, initialDueDate: ค่าเริ่มต้นที่แสดงในฟอร์ม (ใช้สำหรับโหมด "แก้ไข")
// onSave: ฟังก์ชัน callback เมื่อผู้ใช้กดปุ่ม Save
class TodoFormDialogWidget extends StatefulWidget {
  final bool isEdit;
  final String? initialTitle;
  final String? initialPriority;
  final String? initialStatus;
  final DateTime? initialDueDate;
  final Function(
    String,
    String,
    String,
    DateTime,
  ) onSave;

  const TodoFormDialogWidget({
    super.key,
    required this.isEdit,
    required this.initialTitle,
    required this.initialPriority,
    required this.initialStatus,
    required this.initialDueDate,
    required this.onSave,
  });

  // สร้าง State ที่ชื่อ TodoFormDialogWidgetState 
  // เพื่อเก็บข้อมูลที่สามารถเปลี่ยนแปลงได้ เช่น ค่าที่ผู้ใช้งานเลือกใน Dropdown หรือกรอกใน TextField
  @override
  TodoFormDialogWidgetState createState() {
    return TodoFormDialogWidgetState();
  }
}

class TodoFormDialogWidgetState extends State<TodoFormDialogWidget> {
  // keyword "late" ใช้เมื่อต้องการกำหนดค่าให้ตัวแปรในภายหลัง
  late TextEditingController _titleController;
  late String? _selectedPriority;
  late String? _selectedStatus;
  late DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();

    // กำหนดค่าตัวแปรเริ่มต้น เช่น ถ้าไม่มีค่าเริ่มต้นจาก widget.initial... จะใช้ค่า default แทน
    _titleController = TextEditingController(text: widget.initialTitle);
    _selectedPriority = widget.initialPriority ?? ToDoPriority.low;
    _selectedStatus = widget.initialStatus ?? ToDoStatus.pending;
    _selectedDueDate = widget.initialDueDate;
  }

  @override
  void dispose() {
    // ล้างค่าตัวแปร _titleController ก่อนเปิด dialog เพื่อป้องกัน memory leak
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // หัวข้อของ Dialog จะแสดงเป็น "Edit" หรือ "Add" ตาม widget.isEdit
    final title = widget.isEdit ? const Text('Edit') : const Text('Add');

    // ไอคอนของ Dialog จะแสดงเป็น "Edit" หรือ "Add" ตาม widget.isEdit
    final titleIcon = widget.isEdit ? Icons.edit : Icons.add;

    // widget สำหรับกำหนดช่องวางระหว่าง input field
    const spacer = SizedBox(height: 15);

    return AlertDialog(
      title: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(
              titleIcon,
              size: 20,
            ),
          ),
          title,
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ช่องกรอกชื่อ
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Enter a task',
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
            ),
            spacer,
            // Dropdown สำหรับ Status
            // ใช้ ToDoStatus.allStatuses สำหรับสร้างตัวเลือกใน Dropdown
            // เก็บค่าไว้ใน _selectedStatus
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Status:'),
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedStatus,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }
              },
              items: ToDoStatus.allStatuses.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item.toUpperCase()),
                );
              }).toList(),
            ),
            spacer,
            // Dropdown สำหรับ Priority
            // ใช้ ToDoStatus._selectedPriority สำหรับสร้างตัวเลือกใน Dropdown
            // เก็บค่าไว้ใน _selectedPriority
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Priority:'),
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedPriority,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPriority = value;
                  });
                }
              },
              items: ToDoPriority.allStatuses.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item.toUpperCase()),
                );
              }).toList(),
            ),
            spacer,
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Due Date:'),
            ),
            const SizedBox(height: 5),
            // ปุ่มเลือก Due Date
            // เก็บค่าไว้ใน _selectedDueDate
            TextButton(
              onPressed: () async {
                // แสดง DatePicker เมื่อกดปุ่ม
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                // date ที่เลือก ถูกเก็บไว้ใน pickedDate
                // ถ้าไม่เท่ากับ null ให้กำหนดค่าให้ _selectedDueDate
                if (pickedDate != null) {
                  setState(() {
                    _selectedDueDate = pickedDate;
                  });
                }
              },
              // text widget สำหรับแสดงค่า due date โดยแสดงใน format dd-MMM-yyyy
              child: Text(
                _selectedDueDate == null
                    ? 'Select Due Date'
                    : DateFormat('dd-MMM-yyyy')
                        .format(_selectedDueDate!.toLocal()),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      actions: [
        // ปุ่มยกเลิก
        TextButton(
          // ปิด Dialog
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        // ปุ่มบันทึกข้อมูล
        TextButton(
          child: const Text('Save'),
          onPressed: () {
            // validate ข้อมูล todo
            if (_titleController.text.isEmpty ||
                _selectedStatus == null ||
                _selectedPriority == null ||
                _selectedDueDate == null) {
              return;
            }

            // เรียก callback function สำหรับบันทึกข้อมูล
            widget.onSave(
              _titleController.text,
              _selectedPriority!,
              _selectedStatus!,
              _selectedDueDate!,
            );

            // ปิด Dialog
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
