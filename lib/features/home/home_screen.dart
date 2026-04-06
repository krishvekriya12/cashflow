import 'package:cashflow/core/constants/material.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../analytics/analytics_screen.dart';
import '../add_expense/add_expense_screen.dart';
import '../reports/reports_screen.dart';
import '../profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeContent(),
    AnalyticsScreen(),
    ReportsScreen(),
    ProfileScreen(),
  ];

  void _openAddExpenseModal(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: const AddExpenseScreen(),
        );
      },
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddExpenseModal(context),
        backgroundColor: AppColors.primary,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: CashFlowBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _name = "User";
  String _currency = "₹";
  late Box _box;

  @override
  void initState() {
    super.initState();
    _box = Hive.box('transactions');
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? "User";
      _currency = prefs.getString('currency')?.split(' ')[0] ?? "₹";
    });
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning! ☀️";
    if (hour < 17) return "Good Afternoon! 🌤️";
    return "Good Evening! 🌙";
  }

  double get _totalIncome {
    return _box.values
        .where((t) => t['type'] == 'Income')
        .fold(0.0, (sum, t) => sum + (t['amount'] as double));
  }

  double get _totalExpense {
    return _box.values
        .where((t) => t['type'] == 'Expense')
        .fold(0.0, (sum, t) => sum + (t['amount'] as double));
  }

  double get _balance => _totalIncome - _totalExpense;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _box.listenable(),
      builder: (context, box, child) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildBalanceCard(),
                const SizedBox(height: 24),
                _buildIncomeExpenseRow(),
                const SizedBox(height: 24),
                _buildRecentTransactions(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting, // ✅ Fixed: time-based greeting
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            Text(
              _name,
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.notifications_rounded,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C896), Color(0xFF00A878)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Balance",
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.8), // ✅ Fixed deprecated
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              "$_currency ${_balance.toStringAsFixed(2)}",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                DateFormat('MMMM yyyy').format(DateTime.now()),
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(
                    alpha: 0.8,
                  ), // ✅ Fixed deprecated
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
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
                    color: AppColors.income.withValues(alpha: 0.15), // ✅ Fixed
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_downward_rounded,
                    color: AppColors.income,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Income",
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "$_currency ${_totalIncome.toStringAsFixed(0)}",
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
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
                    color: AppColors.expense.withValues(alpha: 0.15), // ✅ Fixed
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_upward_rounded,
                    color: AppColors.expense,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Expense",
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "$_currency ${_totalExpense.toStringAsFixed(0)}",
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    final transactions = _box.toMap().entries.toList().reversed.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recent Transactions",
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
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded, size: 64, color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Your journey begins here!",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                  ),
                ),
              ],
            ))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final entry = transactions[index];
                  final key = entry.key;
                  final t = entry.value as Map;
                  final isExpense = t['type'] == 'Expense';
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
                                ? AppColors.expense.withValues(
                                    alpha: 0.15,
                                  ) // ✅ Fixed
                                : AppColors.income.withValues(
                                    alpha: 0.15,
                                  ), // ✅ Fixed
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
                                t['note'].isEmpty ? t['type'] : t['note'],
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
    );
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
}
