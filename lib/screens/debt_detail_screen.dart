import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/debt.dart';
import '../providers/debt_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import 'add_debt_screen.dart';

class DebtDetailScreen extends StatelessWidget {
  final Debt debt;
  const DebtDetailScreen({super.key, required this.debt});

  @override
  Widget build(BuildContext context) {
    final isLend = debt.type == 'lend';
    final color = isLend ? AppTheme.green : AppTheme.red;
    final currency = context.watch<AuthProvider>().currency;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: AppTheme.textPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                    child: Text('تفاصيل الدين',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary))),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: AppTheme.gold),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AddDebtScreen(debt: debt))),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppTheme.red),
                  onPressed: () => _delete(context),
                ),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  // Avatar card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: AppTheme.glassCard,
                    child: Column(children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: color.withOpacity(0.4), width: 2),
                        ),
                        child: Center(
                          child: Text(
                            debt.name.isNotEmpty
                                ? debt.name[0]
                                : '؟',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: color),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(debt.name,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary)),
                      const SizedBox(height: 4),
                      Text(debt.phone,
                          style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: color.withOpacity(0.3)),
                        ),
                        child: Text(
                          isLend ? '↑ أقرضت' : '↓ اقترضت',
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w700,
                              fontSize: 13),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // Amounts
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.glassCard,
                    child: Column(children: [
                      _row('المبلغ الكلي',
                          '${debt.amount.toStringAsFixed(2)} $currency',
                          color: AppTheme.textPrimary),
                      _divider(),
                      _row('المدفوع',
                          '${debt.paidAmount.toStringAsFixed(2)} $currency',
                          color: AppTheme.green),
                      _divider(),
                      _row('المتبقي',
                          '${debt.remainingAmount.toStringAsFixed(2)} $currency',
                          color: AppTheme.red,
                          bold: true),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: debt.progressPercent,
                          backgroundColor: AppTheme.border,
                          valueColor:
                              AlwaysStoppedAnimation(color),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                          '${(debt.progressPercent * 100).toStringAsFixed(0)}% مدفوع',
                          style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12)),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // Dates & status
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.glassCard,
                    child: Column(children: [
                      _row('تاريخ الإنشاء',
                          '${debt.createdAt.day}/${debt.createdAt.month}/${debt.createdAt.year}'),
                      if (debt.dueDate != null) ...[
                        _divider(),
                        _row('تاريخ الاستحقاق',
                            '${debt.dueDate!.day}/${debt.dueDate!.month}/${debt.dueDate!.year}',
                            color: debt.isOverdue
                                ? AppTheme.red
                                : AppTheme.textPrimary),
                      ],
                      if (debt.note != null) ...[
                        _divider(),
                        _row('ملاحظة', debt.note!),
                      ],
                      _divider(),
                      _row(
                          'الحالة',
                          debt.isSettled ? 'مسوّى ✓' : 'قيد التسوية',
                          color: debt.isSettled
                              ? AppTheme.green
                              : AppTheme.gold),
                    ]),
                  ),

                  if (!debt.isSettled) ...[
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _payment(context, currency),
                          icon: const Icon(Icons.payments_outlined,
                              size: 18),
                          label: const Text('دفعة جزئية'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: color,
                            side: BorderSide(color: color),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14)),
                            textStyle: const TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _settle(context),
                          icon: const Icon(Icons.check_circle_outline,
                              size: 18),
                          label: const Text('تسوية كاملة'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ]),
                  ],
                  const SizedBox(height: 30),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _row(String l, String v,
      {Color? color, bool bold = false}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
          Text(v,
              style: TextStyle(
                  color: color ?? AppTheme.textPrimary,
                  fontWeight:
                      bold ? FontWeight.w800 : FontWeight.w600,
                  fontSize: bold ? 17 : 13,
                  fontFamily: 'Cairo')),
        ],
      );

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Divider(color: AppTheme.border, height: 1),
      );

  void _delete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف الدين',
            style: TextStyle(
                color: AppTheme.textPrimary, fontFamily: 'Cairo')),
        content: const Text('هل أنت متأكد من حذف هذا السجل؟',
            style: TextStyle(
                color: AppTheme.textSecondary, fontFamily: 'Cairo')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء',
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontFamily: 'Cairo'))),
          TextButton(
            onPressed: () async {
              await context
                  .read<DebtProvider>()
                  .deleteDebt(debt.id!);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('حذف',
                style: TextStyle(
                    color: AppTheme.red, fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  void _settle(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('تسوية الدين',
            style: TextStyle(
                color: AppTheme.textPrimary, fontFamily: 'Cairo')),
        content: const Text(
            'سيتم تحديد هذا الدين كمسوّى بالكامل.',
            style: TextStyle(
                color: AppTheme.textSecondary, fontFamily: 'Cairo')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء',
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontFamily: 'Cairo'))),
          TextButton(
            onPressed: () async {
              await context.read<DebtProvider>().settleDebt(debt);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('تأكيد',
                style: TextStyle(
                    color: AppTheme.green, fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  void _payment(BuildContext context, String currency) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('إضافة دفعة',
            style: TextStyle(
                color: AppTheme.textPrimary, fontFamily: 'Cairo')),
        content: TextField(
          controller: ctrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(
              color: AppTheme.textPrimary, fontFamily: 'Cairo'),
          decoration: InputDecoration(
            hintText: 'المبلغ المدفوع',
            suffixText: currency,
            suffixStyle: const TextStyle(
                color: AppTheme.gold, fontFamily: 'Cairo'),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء',
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontFamily: 'Cairo'))),
          TextButton(
            onPressed: () async {
              final v = double.tryParse(
                  ctrl.text.replaceAll(',', '.'));
              if (v != null && v > 0) {
                await context
                    .read<DebtProvider>()
                    .addPayment(debt, v);
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('إضافة',
                style: TextStyle(
                    color: AppTheme.gold, fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}
