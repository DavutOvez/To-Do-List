import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ToDoList());
  }
}

class ToDoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ToDoListState();
}

class ToDoListState extends State<ToDoList> {
  List<bool> checked_list = [];

  @override
  void initState() {
    super.initState();
    loadTasks().then((loadedTasks) {
      setState(() {
        tasks = loadedTasks;
      });
    });
  }

  Future<void> deleteTask(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('task_list');
    if (tasksJson == null) return;

    List<dynamic> currentTasks = jsonDecode(tasksJson);
    if (index < 0 || index >= currentTasks.length) return;

    currentTasks.removeAt(index);
    final String updatedTasksJson = jsonEncode(currentTasks);
    await prefs.setString('task_list', updatedTasksJson);

    setState(() {
      tasks = currentTasks;
      checked_list = List.filled(tasks.length, false, growable: true);
    });
  }

  Future<void> saveTasks(List<dynamic> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(tasks);
    await prefs.setString('task_list', encodedData);
  }

  Future<List<dynamic>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('task_list');
    if (tasksJson == null) return [];

    return jsonDecode(tasksJson);
  }

  TextEditingController taskController = TextEditingController();
  List<dynamic> tasks = [];
  int? editingIndex;

  void addOrUpdateTask(String taskName) {
    if (editingIndex != null) {
      tasks[editingIndex!] = {'task': taskName};
      editingIndex = null;
    } else {
      tasks.add({'task': taskName});
      checked_list.add(false);
    }

    saveTasks(tasks);
    taskController.clear();
  }

  Future<List<dynamic>> ReadDataDict() async {
    return await loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[300],
      body: Column(
        children: [
          Container(
            height: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(),
                  child: Column(
                    children: [
                      SizedBox(height: 100, width: double.infinity),
                      Row(
                        children: [
                          SizedBox(width: 40),
                          Text(
                            'To  Do List ',
                            style: TextStyle(
                              fontSize: 45,
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Icon(Icons.edit, size: 45, color: Colors.white70),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 100),
                        child: Text(
                          '~ Plan It , Do it , Own it ~',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(45),
              ),
              child: Column(
                children: [
                  SizedBox(height: 40),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 25, right: 10),
                        child: Text(
                          'Enter Task:',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: TextField(
                          controller: taskController,
                          decoration: InputDecoration(
                            hint: Text('Example '),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (taskController.text.isNotEmpty) {
                              setState(() {
                                addOrUpdateTask(taskController.text);
                                taskController.clear();
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shadowColor: null,
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            foregroundColor: null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.zero,
                            ),
                          ),
                          child: Text(
                            editingIndex == null ? '+' : '✔',
                            style: TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                    ],
                  ),
                  SizedBox(height: 15),
                  Divider(thickness: 15.0),
                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: ReadDataDict(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(child: Text('Task not found'));
                        }

                        final tasks = snapshot.data;
                        if (checked_list.length != tasks!.length) {
                          checked_list =
                              List.filled(tasks.length, false, growable: true);
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            final isChecked = checked_list[index];
                            return ListTile(
                              leading: IconButton(
                                onPressed: () {
                                  setState(() {
                                    checked_list[index] = !isChecked;
                                  });
                                },
                                icon: Icon(
                                  color: isChecked ? Colors.green : Colors.black,
                                  isChecked
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank_outlined,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(),
                                    child: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          checked_list[index] = !isChecked;
                                        });
                                      },
                                      child: Text(
                                        task['task'] ?? 'salam',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 25,
                                          decoration: isChecked
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        taskController.text = tasks[index]['task'];
                                        editingIndex = index;
                                      });
                                    },
                                    icon: Icon(Icons.edit, color: Colors.amber),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        deleteTask(index);
                                      });
                                    },
                                    icon: Icon(Icons.delete, color: Colors.red),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}