import 'package:flutter/material.dart';
import 'package:schedule_generator/models/task.dart';
import 'package:schedule_generator/services/gemini_services.dart';
import 'package:schedule_generator/ui/home_components/generate_button.dart';
import 'package:schedule_generator/ui/home_components/result_screen.dart';
import 'package:schedule_generator/ui/home_components/task_input.dart';
import 'package:schedule_generator/ui/home_components/task_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> tasks = [];
  final GeminiServices geminiService = GeminiServices();
  bool isLoading = false;
  String? generatedResult;

  // code handling unutk action penambahan/peng inputan task
  void addTask(Task task) {
    setState(() => tasks.add(task));
  }

  // code handling untuk action penghapusan task yg sudah di input
  void removeTask(int index) {
    setState(() => tasks.removeAt(index));
  }

  // untuk melakukan generate schedule berdasarkan input user
  Future<void> generateSchedule() async {
    setState(() => isLoading = true);
    try {
      final result = await geminiService.generateSchedule(tasks);
      generatedResult = result;
      if (context.mounted) _showSucessDialig();
    } catch (e) {
      // mounted ferif kalau ini beneran dari user yg controll
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Falied to generate: $e")));
      }
    }
    setState(() => isLoading = false);
  }

  void _showSucessDialig() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Congrats!"),
            content: Text("Shedule generated sucessfully."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ResultScreen(
                            result:
                                generatedResult ??
                                "There is no result, Please try to geenrate another tasl",
                          ),
                    ),
                  );
                },
                child: Text("View Result"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sectionColor = Colors.white;
    final sectionTitleStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "Schedule Generator",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: sectionColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Taks Input", style: sectionTitleStyle),
                  SizedBox(height: 12),
                  TaskInputSection(onTaskAdded: addTask),
                ],
              ),
            ),
            SizedBox(height: 10),
            Divider(),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: sectionColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Task List", style: sectionTitleStyle),
                    SizedBox(height: 12),
                    Expanded(
                      child: TaskList(tasks: tasks, onRemove: removeTask),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            GenerateButton(isLoading: isLoading, onPressed: generateSchedule),
          ],
        ),
      ),
    );
  }
}
