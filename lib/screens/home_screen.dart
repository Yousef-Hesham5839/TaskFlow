import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDark;

  const HomeScreen({
    super.key,
    required this.toggleTheme,
    required this.isDark,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  // 💾 Save
  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonList = tasks.map((t) => jsonEncode(t.toJson())).toList();

    await prefs.setStringList('tasks', jsonList);
  }

  // 📥 Load
  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String>? jsonList = prefs.getStringList('tasks');

    if (jsonList != null) {
      setState(() {
        tasks.clear();
        tasks.addAll(
          jsonList.map((e) => Task.fromJson(jsonDecode(e))).toList(),
        );
      });
    }
  }

  // 🔁 Toggle Done
  void toggleTask(int index) {
    setState(() {
      tasks[index].isDone = !tasks[index].isDone;
    });

    saveTasks();
  }

  // 🗑️ Delete
  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });

    saveTasks();
  }

  // ➕ Add via navigation
  void openAddTaskScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTaskScreen(
          onAdd: (value) {
            setState(() {
              tasks.add(Task(title: value));
            });
            saveTasks();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,

      appBar: AppBar(
        title: const Text("TaskFlow"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: widget.toggleTheme,
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),

      // ➕ BODY
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ➕ Add Button (Navigation)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: openAddTaskScreen,
                icon: const Icon(Icons.add),
                label: const Text("Add New Task"),
              ),
            ),

            const SizedBox(height: 20),

            // 📋 LIST
            Expanded(
              child: tasks.isEmpty
                  ? _buildEmptyState(isDark)
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🟡 TO DO
                          if (tasks.any((t) => !t.isDone)) ...[
                            Text(
                              "🟡 To Do",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),

                            ...tasks.where((t) => !t.isDone).map((task) {
                              final index = tasks.indexOf(task);
                              return _buildTaskCard(task, index, isDark);
                            }),
                          ],

                          const SizedBox(height: 20),

                          // 🟢 DONE
                          if (tasks.any((t) => t.isDone)) ...[
                            Text(
                              "🟢 Done",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),

                            ...tasks.where((t) => t.isDone).map((task) {
                              final index = tasks.indexOf(task);
                              return _buildTaskCard(task, index, isDark);
                            }),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 TASK CARD
  Widget _buildTaskCard(Task task, int index, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          // ✔️ Toggle
          GestureDetector(
            onTap: () => toggleTask(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.isDone ? Colors.green : Colors.grey,
                  width: 2,
                ),
                color: task.isDone ? Colors.green : Colors.transparent,
              ),
              child: task.isDone
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            ),
          ),

          const SizedBox(width: 12),

          // 📝 TITLE
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black,
                decoration: task.isDone ? TextDecoration.lineThrough : null,
              ),
            ),
          ),

          // 🗑️ DELETE
          GestureDetector(
            onTap: () => deleteTask(index),
            child: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }

  // 🎯 EMPTY STATE
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.task_alt, size: 90, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            "No Tasks Yet",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Start by adding your first task 🚀",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
