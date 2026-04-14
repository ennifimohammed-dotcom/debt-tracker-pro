import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/debt_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dp = context.watch<DebtProvider>();
    final currency = context.watch<AuthProvider>().currency;
    final lent = dp.totalLent;
    final borrowed = dp.totalBorrowed;
    final total = lent + borrowed;
    final settledPct = dp.settled.isNotEmpty && dp.all.isNotEmpty
        ? (dp.settled.length / (dp.all.length + dp.settled.length) * 100)
        : 0.0;

    final top3 = [...dp.all]
      ..sort((a, b) => b.remainingAmount.compareTo(a.remainingAmount));
    final top = top3.take(3).toList();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: AppTheme.textPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text('الإحصائيات',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary)),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  // Pie chart
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: AppTheme.glassCard,
                    child: Column(children: [
                      const Text('توزيع الديون',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                      const SizedBox(height: 20),
                      total == 0
                          ? const Padding(
                              padding: EdgeInsets.all(32),
                              child: Text('لا توجد بيانات بعد',
                                  style: TextStyle(
                                      color: AppTheme.textSecondary)),
                            )
                          : SizedBox(
                              height: 180,
                              child: PieChart(PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    color: AppTheme.green,
                                    value: lent,
                                    title:
                                        '${(lent / total * 100).toStringAsFixed(0)}%',
                                    radius: 70,
                                    titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Cairo'),
                                  ),
                                  PieChartSectionData(
                                    color: AppTheme.red,
                                    value: borrowed,
                                    title:
                                        '${(borrowed / total * 100).toStringAsFixed(0)}%',
                                    radius: 70,
                                    titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Cairo'),
                                  ),
                                ],
                                sectionsSpace: 3,
                                centerSpaceRadius: 45,
                              )),
                            ),
                      const SizedBox(height: 16),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _legend('أقرضت', AppTheme.green,
                                '${lent.toStringAsFixed(0)} $currency'),
                            const SizedBox(width: 24),
                            _legend('اقترضت', AppTheme.red,
                                '${borrowed.toStringAsFixed(0)} $currency'),
                          ]),
                    ]),
                  ),
                  const SizedBox(height: 14),

                  // Grid stats
                  Row(children: [
                    Expanded(
                        child: _statCard(
                            'الرصيد الصافي',
                            '${dp.netBalance.toStringAsFixed(0)} $currency',
                            Icons.account_balance_wallet_rounded,
                            dp.netBalance >= 0
                                ? AppTheme.green
                                : AppTheme.red)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _statCard(
                            'نسبة المسوّاة',
                            '${settledPct.toStringAsFixed(0)}%',
                            Icons.check_circle_outline_rounded,
                            AppTheme.gold)),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: _statCard(
                            'إجمالي السجلات',
                            '${dp.all.length + dp.settled.length}',
                            Icons.list_alt_rounded,
                            AppTheme.textSecondary)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _statCard(
                            'المتأخرة',
                            '${dp.overdueCount}',
                            Icons.warning_amber_rounded,
                            dp.overdueCount > 0
                                ? AppTheme.red
                                : AppTheme.textSecondary)),
                  ]),

                  if (top.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: AppTheme.glassCard,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('أكبر 3 ديون',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary)),
                            const SizedBox(height: 14),
                            ...top.asMap().entries.map((e) {
                              final rank = e.key + 1;
                              final d = e.value;
                              final isLend = d.type == 'lend';
                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 10),
                                child: Row(children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      gradient: rank == 1
                                          ? AppTheme.goldGradient
                                          : null,
                                      color: rank != 1
                                          ? AppTheme.bgCard2
                                          : null,
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text('$rank',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: rank == 1
                                                  ? Colors.black
                                                  : AppTheme
                                                      .textSecondary)),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: Text(d.name,
                                          style: const TextStyle(
                                              color: AppTheme.textPrimary,
                                              fontWeight:
                                                  FontWeight.w600))),
                                  Text(
                                      '${d.remainingAmount.toStringAsFixed(0)} $currency',
                                      style: TextStyle(
                                          color: isLend
                                              ? AppTheme.green
                                              : AppTheme.red,
                                          fontWeight: FontWeight.w700)),
                                ]),
                              );
                            }),
                          ]),
                    ),
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

  Widget _legend(String label, Color color, String val) => Column(
        children: [
          Row(children: [
            Container(
                width: 12,
                height: 12,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ]),
          const SizedBox(height: 2),
          Text(val,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 11)),
        ],
      );

  Widget _statCard(
      String label, String val, IconData icon, Color color) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.glassCard,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 10),
              Text(val,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: color)),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
            ]),
      );
}
