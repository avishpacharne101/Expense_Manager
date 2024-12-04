import 'package:expense_manager/PersonalPay.dart';
import 'package:flutter/material.dart';
import 'database.dart';
import 'send.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    List<Map<String, dynamic>> receivedTransactions = await _fetchTransactionsFORChat();

    setState(() {
      _transactions = receivedTransactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: const Text("Send Money"),
        leading: const Icon(Icons.arrow_back),
        actions: [
          IconButton(
            onPressed: _fetchTransactions,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {}, // Add help functionality here if needed
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black54,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Send Money",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: "Search",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _transactions.isEmpty
                    ? const Center(child: Text("No transactions found"))
                    : ListView.builder(
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = _transactions[index];
                          return transactionItem(
                            transaction['receiver'] ?? 'Unknown',
                            transaction['amount'].toString(),
                            transaction['timestamp'] ?? 'No Date',
                          );
                        },
                      ),
              ),
            ],
          ),
          Positioned(
            bottom: 70,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Send('')),
                );
                if (result == true) {
                  _fetchTransactions();
                }
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget transactionItem(String name, String amount, String date) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return PaymentScreen(name);
        }));
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                 // Text('₹$amount', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            Text(date, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

Future<List<Map<String, dynamic>>> _fetchTransactionsFORChat() async {
  List<Map<String, dynamic>> receivedTransactions = await fetchTransactions();

  // Filter to only keep the latest transaction for each unique receiver
  Map<String, Map<String, dynamic>> uniqueTransactions = {};
  for (var transaction in receivedTransactions) {
    final receiver = transaction['receiver'] ?? 'Unknown';
    final sender = transaction['sender'] ?? 'unknown';
    final timestamp = transaction['timestamp'] ?? '';
    
    if (uniqueTransactions.containsKey(receiver) ) {
      // Compare timestamps to keep the latest transaction
      if (DateTime.parse(timestamp).isAfter(DateTime.parse(uniqueTransactions[receiver]!['timestamp']))) {
        uniqueTransactions[receiver] = transaction;
      }
    } else {
      uniqueTransactions[receiver] = transaction;
    }
  }

  // Return the filtered transactions as a list
  return uniqueTransactions.values.toList();
}