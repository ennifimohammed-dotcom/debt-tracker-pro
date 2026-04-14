import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/debt_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/debt_card.dart';
import '../widgets/stat_mini_card.dart';
import 'add_debt_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _searchCtrl = TextEditingController();
  bool _searchOpen = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DebtProvider>().load();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dp = context.watch<DebtProvider>();
    final auth = context.watch<AuthProvider>();
    final isPos = dp.netBalance >= 0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          bottom: false,
          child: Column(children: [
            // ── TOP BAR ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('مرحباً 👋',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary)),
                      const Text('Debt Tracker Pro',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary)),
                    ],
                  ),
                ),
                _iconBtn(Icons.search_rounded, () {
                  setState(() => _searchOpen = !_searchOpen);
                  if (!_searchOpen) {
                    _searchCtrl.clear();
                    dp.setSearch('');
                  }
                }),
                _iconBtn(Icons.bar_chart_rounded, () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const StatsScreen()))),
                _iconBtn(Icons.settings_outlined, () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SettingsScreen()))),
              ]),
            ),

            // ── SEARCH BAR ──
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: _searchOpen
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: TextField(
                        controller: _searchCtrl,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'بحث بالاسم أو الهاتف...',
                          prefixIcon: const Icon(Icons.search,
                              color: AppTheme.textSecondary),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear,
                                color: AppTheme.textSecondary, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              dp.setSearch('');
                            },
                          ),
                        ),
                        onChanged: dp.setSearch,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 20),

            // ── NET BALANCE CARD ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: AppTheme.goldGlassCard(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.gold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('الرصيد الصافي',
                            style: TextStyle(
                                color: AppTheme.gold,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isPos ? AppTheme.green : AppTheme.red)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(children: [
                          Icon(
                              isPos
                                  ? Icons.trending_up_rounded
                                  : Icons.trending_down_rounded,
                              color: isPos ? AppTheme.green : AppTheme.red,
                              size: 14),
                          const SizedBox(width: 4),
                          Text(isPos ? 'موجب' : 'سالب',
                              style: TextStyle(
                                  color: isPos ? AppTheme.green : AppTheme.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 14),
                    ShaderMask(
                      shaderCallback: (b) =>
                          AppTheme.goldGradient.createShader(b),
                      child: Text(
                        '${dp.netBalance.toStringAsFixed(2)} ${auth.currency}',
                        style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── 4 MINI STAT CARDS ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Expanded(
                    child: StatMiniCard(
                        label: 'أقرضت',
                        value: '${dp.totalLent.toStringAsFixed(0)} ${auth.currency}',
                        icon: Icons.arrow_upward_rounded,
                        color: AppTheme.green)),
                const SizedBox(width: 10),
                Expanded(
                    child: StatMiniCard(
                        label: 'اقترضت',
                        value: '${dp.totalBorrowed.toStringAsFixed(0)} ${auth.currency}',
                        icon: Icons.arrow_downward_rounded,
                        color: AppTheme.red)),
              ]),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Expanded(
                    child: StatMiniCard(
                        label: 'عدد الأشخاص',
                        value: '${dp.lentCount + dp.borrowedCount}',
                        icon: Icons.people_outline_rounded,
                        color: AppTheme.gold)),
                const SizedBox(width: 10),
                Expanded(
                    child: StatMiniCard(
                        label: 'متأخرة',
                        value: '${dp.overdueCount}',
                        icon: Icons.warning_amber_rounded,
                        color: dp.overdueCount > 0
                            ? AppTheme.red
                            : AppTheme.textSecondary)),
              ]),
            ),

            const SizedBox(height: 16),

            // ── TABS ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: TabBar(
                controller: _tabs,
                indicator: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.black,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(text: 'الكل (${dp.all.length})'),
                  Tab(text: 'أقرضت (${dp.lentCount})'),
                  Tab(text: 'اقترضت (${dp.borrowedCount})'),
                ],
              ),
            ),

            // ── LIST ──
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _list(dp.all),
                  _list(dp.lent),
                  _list(dp.borrowed),
                ],
              ),
            ),
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AddDebtScreen()));
        },
        backgroundColor: AppTheme.gold,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('إضافة دين',
            style: TextStyle(
                fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        elevation: 8,
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Icon(icon, color: AppTheme.textSecondary, size: 20),
        ),
      );

  Widget _list(List list) {
    if (list.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.inbox_rounded, size: 64, color: AppTheme.border),
          const SizedBox(height: 12),
          const Text('لا توجد سجلات',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 15)),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      itemCount: list.length,
      itemBuilder: (_, i) => DebtCard(debt: list[i]),
    );
  }
}
