import 'package:flutter/material.dart';
import 'package:schedule_generator/models/task.dart';

class TaskInputSection extends StatefulWidget {
  final void Function(Task) onTaskAdded;

  const TaskInputSection({super.key, required this.onTaskAdded});

  @override
  State<TaskInputSection> createState() => _TaskInputSectionState();
}

class _TaskInputSectionState extends State<TaskInputSection> {
  final taskController = TextEditingController();
  final durationController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  void _addTask() {
    if (taskController.text.isEmpty ||
        durationController.text.isEmpty ||
        selectedDate == null ||
        selectedTime == null) return;

    final deadline = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    widget.onTaskAdded(Task(
      name: taskController.text,
      duration: int.tryParse(durationController.text) ?? 0,
      deadline: deadline,
    ));

    taskController.clear();
    durationController.clear();
    setState(() {
      selectedDate = null;
      selectedTime = null;
    });
  }

  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  void _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) setState(() => selectedTime = time);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.all(1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: taskController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                labelText: 'Task Name',
                prefixIcon: Icon(Icons.task_alt,color: const Color.fromARGB(255, 44, 76, 255)),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                fillColor: Colors.white,
                labelText: "Duration (minutes)",
                prefixIcon: Icon(Icons.timer, color: const Color.fromARGB(255, 44, 76, 255)),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: Icon(Icons.calendar_today),
                    label: Text(selectedDate == null
                        ? "Pick Date"
                        : "${selectedDate!.toLocal()}".split(' ')[0]),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: Icon(Icons.access_time),
                    label: Text(selectedTime == null
                        ? "Pick Time"
                        : selectedTime!.format(context)),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _addTask,
              icon: Icon(Icons.add, color: const Color.fromARGB(255, 44, 76, 255)),
              label: Text("Add Task", style: TextStyle(color: const Color.fromARGB(255, 44, 76, 255), fontWeight: FontWeight.w500),),
              style: FilledButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 176, 220, 255),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
