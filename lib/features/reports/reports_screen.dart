import 'package:cashflow/core/constants/material.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late Box _box;
  DateTime _selectedMonth = DateTime.now();
  String _currency = '₹';

  @override
  void initState() {
    super.initState();
    _box = Hive.box('transactions');
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currency = prefs.getString('currency')?.split(' ')[0] ?? '₹';
    });
  }

  List<MapEntry<dynamic, dynamic>> get _filteredTransactions {
    return _box.toMap().entries
        .where((entry) {
          final t = entry.value as Map;
          final date = DateTime.parse(t['date']);
          return date.month == _selectedMonth.month &&
              date.year == _selectedMonth.year;
        })
        .toList()
        .reversed
        .toList();
  }

  double get _monthlyIncome {
    return _filteredTransactions
        .where((entry) => (entry.value as Map)['type'] == 'Income')
        .fold(0.0, (sum, entry) => sum + ((entry.value as Map)['amount'] as double));
  }

  double get _monthlyExpense {
    return _filteredTransactions
        .where((entry) => (entry.value as Map)['type'] == 'Expense')
        .fold(0.0, (sum, entry) => sum + ((entry.value as Map)['amount'] as double));
  }

  String get _monthName {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[_selectedMonth.month - 1]} ${_selectedMonth.year}';
  }

  String _getCategoryEmoji(String category) {
    const emojis = {
      'Food': '🍔',
      'Transport': '🚗',
      'Shopping': '🛍️',
      'Bills': '💡',
      'Health': '💊',
      'Entertainment': '🎬',
      'Education': '📚',
      'Other': '💰',
    };
    return emojis[category] ?? '💰';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _box.listenable(),
      builder: (context, box, _) {
        final transactions = _filteredTransactions;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            title: Text(
              "Reports",
              style: GoogleFonts.poppins(color: AppColors.textPrimary),
            ),
          ),
          body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month - 1,
                      );
                    });
                  },
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _monthName,
                  style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_selectedMonth.month < DateTime.now().month ||
                        _selectedMonth.year < DateTime.now().year) {
                      setState(() {
                        _selectedMonth = DateTime(
                          _selectedMonth.year,
                          _selectedMonth.month + 1,
                        );
                      });
                    }
                  },
                  icon: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    "Income",
                    "$_currency ${_monthlyIncome.toStringAsFixed(0)}",
                    AppColors.income,
                    Icons.arrow_downward_rounded,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    "Expense",
                    "$_currency ${_monthlyExpense.toStringAsFixed(0)}",
                    AppColors.expense,
                    Icons.arrow_upward_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C896), Color(0xFF00A878)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Net Balance",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        "$_currency ${(_monthlyIncome - _monthlyExpense).toStringAsFixed(0)}",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Transactions List
            Text(
              "All Transactions",
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            transactions.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.receipt_long_rounded, size: 64, color: AppColors.primary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No transactions this month!",
                          style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final entry = transactions[index];
                      final key = entry.key;
                      final t = entry.value as Map;
                      final isExpense = t['type'] == 'Expense';
                      final date = DateTime.parse(t['date']);

                      return Dismissible(
                        key: Key(key.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Colors.redAccent, Colors.red]),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 30),
                        ),
                        onDismissed: (direction) {
                          HapticFeedback.mediumImpact();
                          _box.delete(key);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: isExpense
                                  ? AppColors.expense.withValues(alpha: 0.15)
                                  : AppColors.income.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  _getCategoryEmoji(t['category']),
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t['category'],
                                    style: GoogleFonts.poppins(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "${date.day}/${date.month}/${date.year}",
                                    style: GoogleFonts.poppins(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "${isExpense ? '-' : '+'} $_currency ${t['amount'].toStringAsFixed(0)}",
                                  style: GoogleFonts.poppins(
                                    color: isExpense
                                        ? AppColors.expense
                                        : AppColors.income,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ));
                    },
                  ),
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildSummaryCard(
    String title,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    amount,
                    style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
