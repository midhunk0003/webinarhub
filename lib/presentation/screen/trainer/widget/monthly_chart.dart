import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lms/core/colors.dart';

class MonthlyBarChart extends StatefulWidget {
  const MonthlyBarChart({super.key});

  @override
  State<MonthlyBarChart> createState() => _MonthlyBarChartState();
}

class _MonthlyBarChartState extends State<MonthlyBarChart> {
  String _selectedTab = 'M'; // Default to Monthly
  int _totalClasses = 126;
  String _percentageChange = '12%';
  bool _isPositive = true;

  // Different data sets for each tab
  final Map<String, List<double>> _chartData = {
    'D': [12, 18, 15, 22, 26, 19, 14, 20, 16, 24, 28, 30], // Daily (12 hours)
    'W': [45, 62, 58, 70, 85, 92, 78, 95, 88, 102, 110, 98], // Weekly
    'M': [12, 18, 15, 22, 26, 19], // Monthly (6 months)
    'Y': [
      120,
      150,
      135,
      180,
      210,
      195,
      220,
      240,
      230,
      260,
      280,
      250,
    ], // Yearly (12 months)
  };

  final Map<String, List<String>> _labels = {
    'D': [
      '6am',
      '8am',
      '10am',
      '12pm',
      '2pm',
      '4pm',
      '6pm',
      '8pm',
      '10pm',
      '12am',
      '2am',
      '4am',
    ],
    'W': ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
    'M': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    'Y': [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ],
  };

  final Map<String, double> _maxYValues = {
    'D': 35,
    'W': 120,
    'M': 30,
    'Y': 300,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              _tab("D", _selectedTab == 'D', () => _updateTab('D')),
              _tab("W", _selectedTab == 'W', () => _updateTab('W')),
              _tab("M", _selectedTab == 'M', () => _updateTab('M')),
              _tab("Y", _selectedTab == 'Y', () => _updateTab('Y')),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColor.formPrimaryColor.withOpacity(0.24),
                AppColor.formSecondaryColor.withOpacity(0.24),
              ],
            ),
            border: Border.all(
              color: AppColor.formBorderColor.withOpacity(0.24),
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "TOTAL CLASSES",
                    style: TextStyle(color: Colors.white54, letterSpacing: 1),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        _totalClasses.toString(),
                        style: const TextStyle(
                          fontSize: 38,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (_isPositive ? Colors.green : Colors.red)
                              .withOpacity(.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isPositive
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: _isPositive ? Colors.green : Colors.red,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              _percentageChange,
                              style: TextStyle(
                                color: _isPositive ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 250,
                child: BarChart(
                  BarChartData(
                    maxY: _maxYValues[_selectedTab]!,
                    alignment: BarChartAlignment.spaceAround,

                    /// Grid
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: _maxYValues[_selectedTab]! / 6,
                      drawVerticalLine: true,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(color: Colors.white12, strokeWidth: .8);
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(color: Colors.white10, strokeWidth: .8);
                      },
                    ),
                    borderData: FlBorderData(show: false),

                    /// Tooltip
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => Colors.black87,
                        tooltipRoundedRadius: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            "${rod.toY.toInt()} Classes",
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),

                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          reservedSize: 35,
                          interval: _maxYValues[_selectedTab]! / 6,
                          showTitles: true,
                          getTitlesWidget:
                              (value, meta) => Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(.7),
                                  fontSize: 11,
                                ),
                              ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final labels = _labels[_selectedTab]!;
                            final index = value.toInt();
                            if (index >= 0 && index < labels.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  labels[index],
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),

                    barGroups: _buildBarGroups(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _updateTab(String tab) {
    setState(() {
      _selectedTab = tab;
      _updateStats(tab);
    });
  }

  void _updateStats(String tab) {
    // Update total classes and percentage based on selected tab
    switch (tab) {
      case 'D':
        _totalClasses = 126;
        _percentageChange = '8%';
        _isPositive = true;
        break;
      case 'W':
        _totalClasses = 845;
        _percentageChange = '15%';
        _isPositive = true;
        break;
      case 'M':
        _totalClasses = 126;
        _percentageChange = '12%';
        _isPositive = true;
        break;
      case 'Y':
        _totalClasses = 1450;
        _percentageChange = '5%';
        _isPositive = false;
        break;
    }
  }

  List<BarChartGroupData> _buildBarGroups() {
    final data = _chartData[_selectedTab]!;
    return List.generate(data.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data[index],
            width: 20,
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xFF005885), Color(0xFF1B8BC8)],
            ),
          ),
        ],
      );
    });
  }
}

Widget _tab(String text, bool selected, VoidCallback onTap) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColor.primaryBlueMid : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}
