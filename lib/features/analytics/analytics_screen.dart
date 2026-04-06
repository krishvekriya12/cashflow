import 'package:cashflow/core/constants/material.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late Box _box;
  int _touchedIndex = -1;
  String _selectedPeriod = 'This Month';
  final List<String> _periods = ['This Week', 'This Month', 'This Year'];

  @override
  void initState() {
    super.initState();
    _box = Hive.box('transactions');
  }

  List get _filteredTransactions {
    final now = DateTime.now();
    return _box.values.where((t) {
      final date = DateTime.parse(t['date']);
      if (_selectedPeriod == 'This Week') {
        return date.isAfter(now.subtract(const Duration(days: 7)));
      } else if (_selectedPeriod == 'This Month') {
        return date.month == now.month && date.year == now.year;
      } else {
        return date.year == now.year;
      }
    }).toList();
  }

  Map<String, double> get _categoryTotals {
    final Map<String, double> totals = {};
    for (var t in _filteredTransactions) {
      if (t['type'] == 'Expense') {
        totals[t['category']] =
            (totals[t['category']] ?? 0) + (t['amount'] as double);
      }
    }
    return totals;
  }

  double get _totalIncome => _filteredTransactions
      .where((t) => t['type'] == 'Income')
      .fold(0.0, (sum, t) => sum + (t['amount'] as double));

  double get _totalExpense => _filteredTransactions
      .where((t) => t['type'] == 'Expense')
      .fold(0.0, (sum, t) => sum + (t['amount'] as double));

  double get _savingsRate {
    if (_totalIncome == 0) return 0;
    return ((_totalIncome - _totalExpense) / _totalIncome * 100);
  }

  final List<Color> _chartColors = [
    const Color(0xFF00C896),
    const Color(0xFFFFD700),
    const Color(0xFFFF6B6B),
    const Color(0xFF7B61FF),
    const Color(0xFF00B4D8),
    const Color(0xFFFF9F43),
    const Color(0xFF48DBFB),
    const Color(0xFFFF6B81),
  ];

  final Map<String, String> _categoryEmojis = {
    'Food': '🍔',
    'Transport': '🚗',
    'Shopping': '🛍️',
    'Bills': '💡',
    'Health': '💊',
    'Entertainment': '🎬',
    'Education': '📚',
    'Other': '💰',
  };

  @override
  Widget build(BuildContext context) {
    final totals = _categoryTotals;
    final totalExpense = totals.values.fold(0.0, (sum, val) => sum + val);
    final sortedTotals = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          "Analytics",
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: _periods.map((period) {
                  final isSelected = _selectedPeriod == period;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPeriod = period),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          period,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    "Income",
                    "₹${_totalIncome.toStringAsFixed(0)}",
                    AppColors.income,
                    Icons.arrow_downward_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    "Expense",
                    "₹${_totalExpense.toStringAsFixed(0)}",
                    AppColors.expense,
                    Icons.arrow_upward_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    "Savings",
                    "${_savingsRate.toStringAsFixed(0)}%",
                    AppColors.accent,
                    Icons.savings_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Pie Chart
            if (totals.isNotEmpty) ...[
              Text(
                "Spending Breakdown",
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 250,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback: (event, response) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        response == null ||
                                        response.touchedSection == null) {
                                      _touchedIndex = -1;
                                      return;
                                    }
                                    _touchedIndex = response
                                        .touchedSection!
                                        .touchedSectionIndex;
                                  });
                                },
                              ),
                              sectionsSpace: 3,
                              centerSpaceRadius: 70,
                              sections: sortedTotals.asMap().entries.map((
                                entry,
                              ) {
                                final index = entry.key;
                                final cat = entry.value;
                                final isTouched = index == _touchedIndex;
                                final percent =
                                    (cat.value / totalExpense * 100);
                                return PieChartSectionData(
                                  color:
                                      _chartColors[index % _chartColors.length],
                                  value: cat.value,
                                  title: isTouched
                                      ? '${percent.toStringAsFixed(1)}%'
                                      : '',
                                  radius: isTouched ? 65 : 55,
                                  titleStyle: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          // Center Text
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Total",
                                style: GoogleFonts.poppins(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                "₹${totalExpense.toStringAsFixed(0)}",
                                style: GoogleFonts.poppins(
                                  color: AppColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFF30363D)),
                    const SizedBox(height: 16),

                    // Legend
                    ...sortedTotals.asMap().entries.map((entry) {
                      final index = entry.key;
                      final cat = entry.value;
                      final percent = (cat.value / totalExpense * 100);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color:
                                    _chartColors[index % _chartColors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _categoryEmojis[cat.key] ?? '💰',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                cat.key,
                                style: GoogleFonts.poppins(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              "${percent.toStringAsFixed(1)}%",
                              style: GoogleFonts.poppins(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "₹${cat.value.toStringAsFixed(0)}",
                              style: GoogleFonts.poppins(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Bar Chart
              Text(
                "Category Wise Spending",
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: sortedTotals.isNotEmpty
                          ? sortedTotals.first.value * 1.3
                          : 100,
                      barGroups: sortedTotals.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.value,
                              gradient: LinearGradient(
                                colors: [
                                  _chartColors[entry.key % _chartColors.length],
                                  _chartColors[entry.key % _chartColors.length]
                                      .withOpacity(0.5),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              width: 22,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ],
                        );
                      }).toList(),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.white.withOpacity(0.05),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
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
                              if (value.toInt() < sortedTotals.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _categoryEmojis[sortedTotals[value.toInt()]
                                            .key] ??
                                        '💰',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Top Spending Category
              Text(
                "Top Spending",
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ...sortedTotals.take(3).toList().asMap().entries.map((entry) {
                final index = entry.key;
                final cat = entry.value;
                final percent = totalExpense > 0
                    ? cat.value / totalExpense
                    : 0.0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            _categoryEmojis[cat.key] ?? '💰',
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              cat.key,
                              style: GoogleFonts.poppins(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            "₹${cat.value.toStringAsFixed(0)}",
                            style: GoogleFonts.poppins(
                              color: AppColors.expense,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percent.toDouble(),
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _chartColors[index % _chartColors.length],
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ] else
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Column(
                    children: [
                      const Text("📊", style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 16),
                      Text(
                        "No expense data yet!",
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Add some expenses to see analytics",
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
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

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
