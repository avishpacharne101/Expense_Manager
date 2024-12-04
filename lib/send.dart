import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_manager/MYHOME.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'database.dart';
final usernameController = TextEditingController();
 final amountController = TextEditingController();
  List<Map<String, dynamic>> transactions = [];
class Send extends StatefulWidget {
  Send(String touser){
    usernameController.text = touser;
  }
  @override
  _SendState createState() => _SendState();
}

class _SendState extends State<Send> {
  String categoryValue = 'Category';
  

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Expense Manager'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Name', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: usernameController,
                
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              const Text('Amount', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              DropdownButtonFormField<String>(
                value: categoryValue,
                onChanged: (String? newValue) {
                  setState(() {
                    categoryValue = newValue!;
                  });
                },
                items: <String>['Category', 'Food', 'Bills', 'Entertainment']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    
                    String receiver = usernameController.text.trim();
                    double amount =
                        double.tryParse(amountController.text) ?? 0.0;
                    String category = categoryValue;

                    if (receiver.isEmpty ||
                        amount <= 0 ||
                        category == 'Category') {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Please provide valid inputs.'),
                        backgroundColor: Colors.red,
                      ));
                      return;
                    }

                    try {
                      String transactionId =
                        DateTime.now().millisecondsSinceEpoch.toString();

                         FirebaseFirestore.instance
                        .collection('transactions')
                        .doc(transactionId)
                        .set({
                          'sender': "$Username"
                          
                          ,'receiver':usernameController.text,
                          
                          'amount': amountController.text,
                          'category': categoryValue,
                          'timestamp': FieldValue.serverTimestamp()
                        })
                        .then((value) => print('Transaction added'))
                        .catchError((error) =>
                            print('Failed to add transaction: $error'));
                      await sendData(receiver, amount, category);
                      Navigator.pop(context, true);

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Transaction saved successfully!'),
                      ));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Failed to save transaction: $e'),
                        backgroundColor: Colors.red,
                      ));
                    }
                    setState(() {
                      usernameController.clear();
                      amountController.clear();
                      categoryValue = 'Category';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100, vertical: 15),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
