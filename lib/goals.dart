import 'package:flutter/material.dart';

class ExpenseGoals extends StatefulWidget {
  @override
  State createState() => _ExpenseGoalsState();
}

class _ExpenseGoalsState extends State<ExpenseGoals> {
  TextEditingController titleController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController totalMoneyController = TextEditingController(); // New controller for total money required

  List<Goal> goals = [];

  void submitGoal(bool isEdit, [Goal? goal]) {
    if (titleController.text.trim().isNotEmpty &&
        noteController.text.trim().isNotEmpty &&
        dateController.text.trim().isNotEmpty &&
        totalMoneyController.text.trim().isNotEmpty) {
      if (isEdit) {
        goal!.title = titleController.text;
        goal.note = noteController.text;
        goal.dueDate = dateController.text;
        goal.totalMoneyRequired = totalMoneyController.text;
        goal.completed_percent = 50;
         // Update total money required for existing goal
      } else {
        goals.add(
          Goal(
            title: titleController.text,
            note: titleController.text,
            dueDate: dateController.text,
            totalMoneyRequired: totalMoneyController.text,
             // Add total money required for new goal
          ),
        );
      }
      clearController();
      Navigator.of(context).pop();
      setState(() {});
    } else {
      // Show an error message if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  void clearController() {
    titleController.clear();
    noteController.clear();
    dateController.clear();
    totalMoneyController.clear(); // Clear the total money field as well
  }

  void openGoalBottomSheet(bool isEdit, [Goal? goal]) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 15,
              left: 15,
              right: 15,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Set Goal",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  " Title ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: " Enter Goal Title ",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  " Note ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
                TextField(
                  minLines: 2,
                  maxLines: 4,
                  controller: noteController,
                  decoration: const InputDecoration(
                    hintText: " Enter Note ",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  " Due Date ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(
                    suffixIcon: GestureDetector(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2026),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            dateController.text = "${pickedDate.toLocal()}".split(' ')[0]; // Format the date to show in TextField
                          });
                        }
                      },
                      child: const Icon(Icons.calendar_month),
                    ),
                    hintText: " Select Due Date",
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  " Total Money Required ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
                TextField(
                  controller: totalMoneyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: " Enter Total Money Required ",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: SizedBox(
                      height: 50,
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () {
                          if (isEdit) {
                            submitGoal(true, goal);
                          } else {
                            submitGoal(false);
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.blue)
                        ),
                        child: Text(
                          "Submit",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Goals",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.person, size: 40),
          onPressed: () {
            // Add action for profile icon here
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, size: 40),
            onPressed: () {
              // Add action for notification icon here
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: goals.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(15),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goals[index].title,
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      goals[index].note,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Total Money Required: ${goals[index].totalMoneyRequired}",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),

                    SizedBox(height: 10,),
                     Text(
                      "Completed  : ${goals[index].completed_percent}%",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          goals[index].dueDate,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            titleController.text = goals[index].title;
                            noteController.text = goals[index].note;
                            dateController.text = goals[index].dueDate;
                            totalMoneyController.text = goals[index].totalMoneyRequired; // Set value for total money field
                            openGoalBottomSheet(true, goals[index]);
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            setState(() {
                              goals.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openGoalBottomSheet(false);
        },
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
     
    );
  }
}

class Goal {
  String title;
  String note;
  String dueDate;
  String totalMoneyRequired;
  int completed_percent = 10;

  Goal({
    required this.title,
    required this.note,
    required this.dueDate,
    required this.totalMoneyRequired,
  });
}
