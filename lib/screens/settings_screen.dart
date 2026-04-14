import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/debt_provider.dart';
import '../services/export_service.dart';
import '../utils/app_theme.dart';
import 'pin_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dp = context.watch<DebtProvider>();

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
                const Text('الإعدادات',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary)),
              ]),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ── SECURITY ──
                  _sectionTitle('🔐 الأمان'),
                  _tile(
                    icon: Icons.lock_outline_rounded,
                    color: AppTheme.gold,
                    title: 'قفل التطبيق بـ PIN',
                    subtitle: auth.lockEnabled ? 'مفعّل' : 'معطّل',
                    trailing: Switch(
                      value: auth.lockEnabled,
                      activeColor: AppTheme.gold,
                      onChanged: (v) => auth.setLockEnabled(v),
                    ),
                  ),
                  if (auth.hasPin)
                    _tile(
                      icon: Icons.edit_outlined,
                      color: AppTheme.gold,
                      title: 'تغيير PIN',
                      subtitle: 'تعديل رمز الدخول السري',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const PinScreen(isChange: true))),
                    )
                  else
                    _tile(
                      icon: Icons.add_circle_outline_rounded,
                      color: AppTheme.green,
                      title: 'إنشاء PIN',
                      subtitle: 'حماية التطبيق برمز سري',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const PinScreen(isSetup: true))),
                    ),

                  const SizedBox(height: 20),

                  // ── CURRENCY ──
                  _sectionTitle('💰 العملة'),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      children: ['درهم', 'دينار', 'ريال', 'جنيه']
                          .map((c) => RadioListTile<String>(
                                title: Text(c,
                                    style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.w600)),
                                value: c,
                                groupValue: auth.currency,
                                activeColor: AppTheme.gold,
                                onChanged: (v) {
                                  if (v != null) auth.setCurrency(v);
                                },
                              ))
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── DATA ──
                  _sectionTitle('📁 البيانات'),
                  _tile(
                    icon: Icons.file_download_outlined,
                    color: AppTheme.green,
                    title: 'تصدير Excel',
                    subtitle: 'مشاركة جميع الديون كملف Excel',
                    onTap: () => ExportService.exportToExcel(
                        dp.all, auth.currency),
                  ),
                  _tile(
                    icon: Icons.delete_outline_rounded,
                    color: AppTheme.red,
                    title: 'حذف جميع البيانات',
                    subtitle: 'إزالة كل الديون نهائياً',
                    onTap: () => _confirmDelete(context, dp),
                  ),

                  const SizedBox(height: 20),

                  // ── ABOUT ──
                  _sectionTitle('ℹ️ حول التطبيق'),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppTheme.goldGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Colors.black,
                            size: 28),
                      ),
                      const SizedBox(height: 12),
                      const Text('Debt Tracker Pro',
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 16)),
                      const SizedBox(height: 4),
                      const Text('الإصدار 2.0.0',
                          style: TextStyle(
                              color: AppTheme.gold, fontSize: 13)),
                      const SizedBox(height: 8),
                      const Text(
                          'تطبيق احترافي لإدارة الديون\nبتصميم فاخر وأمان عالي',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                              height: 1.6)),
                    ]),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(t,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      );

  Widget _tile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(title,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
          subtitle: Text(subtitle,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontFamily: 'Cairo',
                  fontSize: 12)),
          trailing: trailing ??
              (onTap != null
                  ? const Icon(Icons.arrow_forward_ios_rounded,
                      color: AppTheme.textSecondary, size: 14)
                  : null),
        ),
      );

  void _confirmDelete(BuildContext context, DebtProvider dp) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف جميع البيانات',
            style: TextStyle(
                color: AppTheme.textPrimary, fontFamily: 'Cairo')),
        content: const Text(
            'هذا الإجراء لا يمكن التراجع عنه.\nسيتم حذف جميع الديون نهائياً.',
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontFamily: 'Cairo',
                height: 1.6)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء',
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontFamily: 'Cairo'))),
          TextButton(
            onPressed: () async {
              await dp.deleteAll();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('حذف الكل',
                style: TextStyle(
                    color: AppTheme.red, fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}
