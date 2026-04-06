import 'package:cashflow/core/constants/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _selectedCategory = 'Food';
  String _selectedType = 'Expense';
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false; // ✅ Loading state

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': '🍔'},
    {'name': 'Transport', 'icon': '🚗'},
    {'name': 'Shopping', 'icon': '🛍️'},
    {'name': 'Bills', 'icon': '💡'},
    {'name': 'Health', 'icon': '💊'},
    {'name': 'Entertainment', 'icon': '🎬'},
    {'name': 'Education', 'icon': '📚'},
    {'name': 'Other', 'icon': '💰'},
  ];

  @override
  void dispose() {
    // ✅ Fix: Dispose controllers to prevent memory leak
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    HapticFeedback.lightImpact();
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter amount!")));
      return;
    }

    // ✅ Fix: Use tryParse to avoid crash on invalid input
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount!")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final box = Hive.box('transactions');
      await box.add({
        'amount': amount,
        'note': _noteController.text.trim(),
        'category': _selectedCategory,
        'type': _selectedType,
        'date': _selectedDate.toIso8601String(),
      });

      HapticFeedback.mediumImpact();

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      // ✅ Fix: Error handling for Hive operations
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving transaction: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.92,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            title: Text(
              "Add Transaction",
              style: GoogleFonts.poppins(color: AppColors.textPrimary),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_drop_down_rounded,
                color: AppColors.textPrimary,
                size: 32,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Income / Expense Toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: ['Expense', 'Income'].map((type) {
                  final isSelected = _selectedType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (type == 'Income'
                                    ? AppColors.income
                                    : AppColors.expense)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          type,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Amount
            Text(
              "Amount",
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              // ✅ Fix: Only allow numbers and one decimal point
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: 24,
              ),
              decoration: InputDecoration(
                hintText: "0.00",
                hintStyle: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: 24,
                ),
                prefixText: "₹ ",
                prefixStyle: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontSize: 24,
                ),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Note
            Text(
              "Note",
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              style: GoogleFonts.poppins(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: "Add a note...",
                hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category
            Text(
              "Category",
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat['name'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat['name']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.2) // ✅ Fixed
                          : AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(cat['icon'], style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(
                          cat['name'],
                          style: GoogleFonts.poppins(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Date
            Text(
              "Date",
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: AppColors.primary,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                      style: GoogleFonts.poppins(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save Button with loading state
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveTransaction, // ✅ Disable when saving
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        "Save Transaction",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
    ),
    );
  }
}
