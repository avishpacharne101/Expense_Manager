

import 'package:expense_manager/MYHOME.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';



class TransactionsPage extends StatefulWidget {
  @override
  State createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List<Map<String, dynamic>> allTransactions = [];
  bool isLoading = true; // For displaying a loading indicator

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  // Function to fetch all transactions from Firestore
  void fetchTransactions() async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .get(); // Fetch all documents from the 'transactions' collection

    if (querySnapshot.docs.isEmpty) {
      print('No documents found in the transactions collection.');
    }

    // Define the current username
    String? currentUsername = Username; // Replace with the actual value

    // Map Firestore documents to a list of transactions
    List<Map<String, dynamic>> transactions = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return {
        'sender': data['sender'] ?? 'Unknown Sender',
        'receiver': data['receiver'] ?? 'Unknown Receiver',
        'amount': int.tryParse(data['amount'].toString()) ?? 0,
        'timestamp': data['timestamp'] != null
            ? (data['timestamp'] as Timestamp).toDate()
            : DateTime.now(),
        'category': data['category'] ?? 'General',
      };
    }).toList();

    // Filter transactions where the current user is either the sender or receiver
    List<Map<String, dynamic>> filteredTransactions = transactions.where((transaction) {
      final sender = transaction['sender'];
      final receiver = transaction['receiver'];
      return sender == currentUsername || receiver == currentUsername;
    }).toList();

    print('Filtered transactions: $filteredTransactions');

    setState(() {
      allTransactions = filteredTransactions;
      isLoading = false; // Stop loading indicator
    });
  } catch (e) {
    print('Error fetching transactions: $e');
    setState(() {
      isLoading = false; // Stop loading indicator even on error
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
    //    backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : allTransactions.isEmpty
              ? Center(
                  child: Text(
                    'No Transactions Found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: allTransactions.length,
                  itemBuilder: (context, index) {
                    final data = allTransactions[index];
                    return TransactionTile(
                      sender: data['sender'],
                      receiver: data['receiver'],
                      amount: data['amount'],
                      timestamp: data['timestamp'],
                      category: data['category'],
                    );
                  },
                ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final String sender;
  final String receiver;
  final int amount;
  final DateTime timestamp;
  final String category;

  TransactionTile({
    required this.sender,
    required this.receiver,
    required this.amount,
    required this.timestamp,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: Colors.purpleAccent,
            child: Text(sender[0].toUpperCase(), style: TextStyle(color: Colors.white)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$sender ➡ $receiver',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${timestamp.toLocal()}'.split('.')[0], // Display date and time
                  style: TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹$amount',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color:(sender == Username) ? Colors.red : Colors.green,
                ),
              ),
              SizedBox(height: 4),
              Text(
                category,
                style: TextStyle(fontSize: 12.0, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
