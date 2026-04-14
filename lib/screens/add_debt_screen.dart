import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/debt.dart';
import '../providers/debt_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

class AddDebtScreen extends StatefulWidget {
  final Debt? debt;
  const AddDebtScreen({super.key, this.debt});
  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  String _type = 'lend';
  DateTime? _dueDate;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.debt != null) {
      final d = widget.debt!;
      _name.text = d.name;
      _phone.text = d.phone;
      _amount.text = d.amount.toStringAsFixed(2);
      _note.text = d.note ?? '';
      _type = d.type;
      _dueDate = d.dueDate;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final dp = context.read<DebtProvider>();
      final currency = context.read<AuthProvider>().currency;
      final debt = Debt(
        id: widget.debt?.id,
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        amount: double.parse(_amount.text.replaceAll(',', '.')),
        paidAmount: widget.debt?.paidAmount ?? 0.0,
        type: _type,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        createdAt: widget.debt?.createdAt ?? DateTime.now(),
        dueDate: _dueDate,
      );
      if (widget.debt == null) {
        await dp.addDebt(debt);
      } else {
        await dp.updateDebt(debt);
      }
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded,
              color: Colors.black, size: 18),
          const SizedBox(width: 8),
          Text(
            widget.debt == null
                ? 'تم إضافة الدين بنجاح ✓'
                : 'تم تحديث الدين بنجاح ✓',
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
                color: Colors.black),
          ),
        ]),
        backgroundColor: AppTheme.green,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
      // ignore: unused_local_variable
      final _ = currency;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('خطأ: $e',
            style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppTheme.red,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.debt != null;
    final currency = context.watch<AuthProvider>().currency;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: AppTheme.textPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  isEdit ? 'تعديل الدين' : 'إضافة دين جديد',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary),
                ),
              ]),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _form,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Type toggle
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.bgCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.border),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Row(children: [
                            _typeBtn('lend', 'أقرضت',
                                Icons.arrow_upward_rounded, AppTheme.green),
                            _typeBtn('borrow', 'اقترضت',
                                Icons.arrow_downward_rounded, AppTheme.red),
                          ]),
                        ),
                        const SizedBox(height: 20),

                        _label('اسم الشخص *'),
                        TextFormField(
                          controller: _name,
                          style: const TextStyle(
                              color: AppTheme.textPrimary),
                          decoration: const InputDecoration(
                            hintText: 'أدخل الاسم الكامل',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'الاسم مطلوب'
                              : null,
                        ),
                        const SizedBox(height: 14),

                        _label('رقم الهاتف *'),
                        TextFormField(
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(
                              color: AppTheme.textPrimary),
                          decoration: const InputDecoration(
                            hintText: '0600000000',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'رقم الهاتف مطلوب'
                              : null,
                        ),
                        const SizedBox(height: 14),

                        _label('المبلغ *'),
                        TextFormField(
                          controller: _amount,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          style: const TextStyle(
                              color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            prefixIcon: const Icon(
                                Icons.monetization_on_outlined),
                            suffixText: currency,
                            suffixStyle: const TextStyle(
                                color: AppTheme.gold,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Cairo'),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'المبلغ مطلوب';
                            }
                            final val = double.tryParse(
                                v.replaceAll(',', '.'));
                            if (val == null || val <= 0) {
                              return 'أدخل مبلغاً صحيحاً أكبر من صفر';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        _label('تاريخ الاستحقاق (اختياري)'),
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.bgCard2,
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: AppTheme.border),
                            ),
                            child: Row(children: [
                              const Icon(Icons.calendar_today_outlined,
                                  color: AppTheme.textSecondary,
                                  size: 20),
                              const SizedBox(width: 12),
                              Text(
                                _dueDate != null
                                    ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                                    : 'اختر تاريخ الاستحقاق',
                                style: TextStyle(
                                    color: _dueDate != null
                                        ? AppTheme.textPrimary
                                        : AppTheme.textSecondary,
                                    fontFamily: 'Cairo'),
                              ),
                              const Spacer(),
                              if (_dueDate != null)
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _dueDate = null),
                                  child: const Icon(Icons.clear,
                                      color: AppTheme.textSecondary,
                                      size: 18),
                                ),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 14),

                        _label('ملاحظة (اختياري)'),
                        TextFormField(
                          controller: _note,
                          maxLines: 3,
                          style: const TextStyle(
                              color: AppTheme.textPrimary),
                          decoration: const InputDecoration(
                            hintText: 'أضف ملاحظة...',
                            prefixIcon: Icon(Icons.notes_outlined),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _save,
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.black,
                                        strokeWidth: 2.5))
                                : Text(
                                    isEdit
                                        ? 'حفظ التعديلات'
                                        : 'إضافة الدين',
                                    style: const TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ]),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _typeBtn(
      String val, String label, IconData icon, Color color) {
    final sel = _type == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = val),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: sel ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: sel
                ? Border.all(color: color.withOpacity(0.5))
                : Border.all(color: Colors.transparent),
          ),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    color: sel ? color : AppTheme.textSecondary,
                    size: 18),
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                        color: sel ? color : AppTheme.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cairo',
                        fontSize: 14)),
              ]),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
      );

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate:
          _dueDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.gold),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() => _dueDate = d);
  }
}
