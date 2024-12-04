import 'package:expense_manager/database.dart'; // Replace with your actual database helper file
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppColors {
  static const contentColorYellow = Colors.yellow;
  static const contentColorRed = Colors.red;
  static const contentColorOrange = Colors.orange;
}

extension ColorUtils on Color {
  Color avg(Color other) {
    return Color.fromARGB(
      (alpha + other.alpha) ~/ 2,
      (red + other.red) ~/ 2,
      (green + other.green) ~/ 2,
      (blue + other.blue) ~/ 2,
    );
  }
}

class BarChartScreen extends StatefulWidget {
   BarChartScreen({super.key});

  final Color leftBarColor = AppColors.contentColorYellow;
  final Color rightBarColor = AppColors.contentColorRed;
  final Color avgColor =
      AppColors.contentColorOrange.avg(AppColors.contentColorRed);

  @override
  State<StatefulWidget> createState() => BarChartScreenState();
}

class BarChartScreenState extends State<BarChartScreen> {
  final double width = 7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context); // Navigate back when pressed
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                makeTransactionsIcon(),
                const SizedBox(width: 38),
                const Text(
                  'Transactions',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ],
            ),
            const SizedBox(height: 38),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchLast7DaysData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    final data = snapshot.data!;
                    final barGroups = data.asMap().entries.map((entry) {
                      final index = entry.key;
                      final amount = (entry.value['amount'] as double);
                      return makeGroupData(index, amount, 0);
                    }).toList();

                    return BarChart(
                      BarChartData(
                        maxY: 250,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '\$${data[group.x.toInt()]['amount']}',
                                const TextStyle(color: Colors.white),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final dayName = data[value.toInt()]['day'];
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 16,
                                  child: Text(
                                    dayName,
                                    style: const TextStyle(
                                      color: Color(0xff7589a2),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              },
                              reservedSize: 42,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              interval: 50,
                              getTitlesWidget: leftTitles,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: barGroups,
                        gridData: const FlGridData(show: false),
                      ),
                    );
                  }
                  return const Center(child: Text('No data available'));
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    return Text(
      value.toInt().toString(),
      style: const TextStyle(
        color: Color(0xff7589a2),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: widget.leftBarColor,
          width: width,
        ),
        BarChartRodData(
          toY: y2,
          color: widget.rightBarColor,
          width: width,
        ),
      ],
    );
  }

  Widget makeTransactionsIcon() {
    const width = 4.5;
    const space = 3.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(width: width, height: 10, color: Colors.white.withOpacity(0.4)),
        const SizedBox(width: space),
        Container(width: width, height: 28, color: Colors.white.withOpacity(0.8)),
        const SizedBox(width: space),
        Container(width: width, height: 42, color: Colors.white.withOpacity(1)),
        const SizedBox(width: space),
        Container(width: width, height: 28, color: Colors.white.withOpacity(0.8)),
        const SizedBox(width: space),
        Container(width: width, height: 10, color: Colors.white.withOpacity(0.4)),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> fetchLast7DaysData() async {
    try {
      final result = await fetchTransactions(); // Replace this with your actual database query
      return result.map((transaction) {
        DateTime timestamp = DateTime.parse(transaction["timestamp"]);
        String day = DateFormat('EEEE').format(timestamp);

        return {"amount": transaction["amount"], "day": day};
      }).toList();
    } catch (e) {
      print('Error fetching data: $e');
      final now = DateTime.now();
      return List.generate(7, (index) {
        DateTime date = now.subtract(Duration(days: index));
        String day = DateFormat('EEEE').format(date);
        double amount = (index + 1) * 20.0;
        return {"day": day, "amount": amount};
      }).reversed.toList();
    }
  }
}
