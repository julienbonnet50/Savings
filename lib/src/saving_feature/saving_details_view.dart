
import 'dart:math';

import 'package:flutter/material.dart';
import 'saving.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:savings/src/saving_feature/saving.dart';
import 'package:intl/intl.dart';

    /* Per day : */
    // final now = DateTime.now();
    // final daysSinceStart = now.difference(startDate).inDays;
    // final dataPoints = List.generate(daysSinceStart + 1, (index) {
    //   final date = startDate.add(Duration(days: index));
    //   final growthRatio = saving.growthRatio / 365; // Assuming the growth ratio is annualized
    //   final currency = saving.currency * pow(1 + growthRatio / 365, index);
    //   return FlSpot(index.toDouble(), currency);
    // });

class SavingDetailsView extends StatelessWidget {
  const SavingDetailsView({super.key, required this.saving});

  static const routeName = '/saving_details';

  final Saving saving;

 @override
Widget build(BuildContext context) {
  final startDate = DateTime.parse(saving.startDate);

  /* Per month */
  final now = DateTime.now();
  final monthsSinceStart = (now.year - startDate.year) * 12 + now.month - startDate.month;
  var xInterval = 6.0;

  if (monthsSinceStart > 36) xInterval = 12.0;

  // Calculate data points for compound interest
  final dataPointsCompound = List.generate(monthsSinceStart + 1, (index) {
    final date = DateTime(startDate.year, startDate.month + index);
    final daysInMonth = DateTime(date.year, date.month + 1).difference(date).inDays;
    final growthRatio = saving.growthRatio / 12; // Assuming the growth ratio is monthly
    final currency = saving.currency * pow(1 + ((growthRatio / 100) / 12), index);
    return FlSpot(index.toDouble(), currency);
  });

  // Calculate data points for basic interest
  final dataPointsBasic = List.generate(monthsSinceStart + 1, (index) {
    final growthRatio = saving.growthRatio / 12; // Assuming the growth ratio is monthly
    final currency = saving.currency * (1 + (((growthRatio/100) / 12) * index));
    return FlSpot(index.toDouble(), currency);
  });

  return Scaffold(
    appBar: AppBar(
      title: Text(saving.name),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Currency growth in K€ per month with ',
                style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: 'Basic interest',
                style: TextStyle(color: Colors.red, fontSize: 25, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: ' and ',
                style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: 'Compound Interest',
                style: TextStyle(color: Colors.blue, fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
          const SizedBox(height: 10.0),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: const FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    axisNameWidget: Text("Months"),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 12
                      ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: Text("K€"),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: dataPointsCompound,
                    color: Colors.blue,
                  ),
                  LineChartBarData(
                    spots: dataPointsBasic,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }
}
