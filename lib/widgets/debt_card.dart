import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/debt.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../screens/debt_detail_screen.dart';

class DebtCard extends StatelessWidget {
  final Debt debt;
  const DebtCard({super.key, required this.debt});

  @override
  Widget build(BuildContext context) {
    final isLend = debt.type == 'lend';
    final color = isLend ? AppTheme.green : AppTheme.red;
    final currency = context.watch<AuthProvider>().currency;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => DebtDetailScreen(debt: debt)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: debt.isOverdue
                ? AppTheme.red.withOpacity(0.4)
                : AppTheme.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
              border:
                  Border.all(color: color.withOpacity(0.3), width: 1.5),
            ),
            child: Center(
              child: Text(
                debt.name.isNotEmpty ? debt.name[0] : '؟',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(debt.name,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                    ),
                    if (debt.isOverdue)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.red.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppTheme.red.withOpacity(0.3)),
                        ),
                        child: const Text('متأخر',
                            style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.red,
                                fontWeight: FontWeight.w700)),
                      ),
                  ]),
                  const SizedBox(height: 3),
                  Text(debt.phone,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary)),
                  if (debt.progressPercent > 0 &&
                      debt.progressPercent < 1.0) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: debt.progressPercent,
                        backgroundColor:
                            AppTheme.border,
                        valueColor:
                            AlwaysStoppedAnimation(color),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ]),
          ),
          const SizedBox(width: 12),

          // Amount
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              '${debt.remainingAmount.toStringAsFixed(0)} $currency',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: color),
            ),
            const SizedBox(height: 5),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isLend ? '↑ أقرضت' : '↓ اقترضت',
                style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
