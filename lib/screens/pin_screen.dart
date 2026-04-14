import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';

class PinScreen extends StatefulWidget {
  final bool isSetup;
  final bool isChange;
  const PinScreen({super.key, this.isSetup = false, this.isChange = false});
  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  String _confirm = '';
  bool _confirming = false;
  bool _error = false;
  String _errorMsg = '';
  int _attempts = 0;
  late AnimationController _shake;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(_shake);
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  void _press(String k) {
    setState(() {
      _error = false;
      if (k == 'del') {
        if (_confirming && _confirm.isNotEmpty) {
          _confirm = _confirm.substring(0, _confirm.length - 1);
        } else if (!_confirming && _pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
        return;
      }
      if (_confirming) {
        if (_confirm.length < 4) {
          _confirm += k;
          if (_confirm.length == 4) _doConfirm();
        }
      } else {
        if (_pin.length < 4) {
          _pin += k;
          if (_pin.length == 4) {
            if (widget.isSetup || widget.isChange) {
              setState(() => _confirming = true);
            } else {
              _doVerify();
            }
          }
        }
      }
    });
  }

  Future<void> _doVerify() async {
    final ok = await context.read<AuthProvider>().verifyPin(_pin);
    if (ok) {
      if (!mounted) return;
      if (widget.isChange) {
        Navigator.pop(context);
        return;
      }
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      _attempts++;
      _shake.forward(from: 0);
      setState(() {
        _error = true;
        _errorMsg = _attempts >= 3
            ? 'محاولات متعددة خاطئة — تحقق من رمزك'
            : 'رمز PIN غير صحيح';
        _pin = '';
      });
    }
  }

  Future<void> _doConfirm() async {
    if (_pin == _confirm) {
      await context.read<AuthProvider>().setPin(_pin);
      if (!mounted) return;
      if (widget.isChange) {
        Navigator.pop(context);
        _showToast('تم تغيير PIN بنجاح ✓');
        return;
      }
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      _shake.forward(from: 0);
      setState(() {
        _error = true;
        _errorMsg = 'الرمزان غير متطابقان، أعد المحاولة';
        _pin = '';
        _confirm = '';
        _confirming = false;
      });
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')),
      backgroundColor: AppTheme.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  String get _title {
    if (widget.isChange) return _confirming ? 'تأكيد PIN الجديد' : 'أدخل PIN الجديد';
    if (widget.isSetup) return _confirming ? 'تأكيد رمز PIN' : 'إنشاء رمز PIN';
    return 'أدخل رمز PIN';
  }

  String get _subtitle {
    if (widget.isSetup && !_confirming) return 'اختر رمزاً سرياً من 4 أرقام';
    if (_confirming) return 'أعد إدخال الرمز للتأكيد';
    return 'أدخل رمزك للدخول إلى حسابك';
  }

  @override
  Widget build(BuildContext context) {
    final current = _confirming ? _confirm : _pin;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(children: [
            const SizedBox(height: 50),
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: AppTheme.gold.withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8))
                ],
              ),
              child: const Icon(Icons.lock_rounded,
                  color: Colors.black, size: 36),
            ),
            const SizedBox(height: 24),
            Text(_title,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Text(_subtitle,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 40),

            // Dots
            AnimatedBuilder(
              animation: _shakeAnim,
              builder: (_, __) => Transform.translate(
                offset: Offset(_error ? _shakeAnim.value : 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final filled = i < current.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled
                            ? (_error ? AppTheme.red : AppTheme.gold)
                            : Colors.transparent,
                        border: Border.all(
                          color: filled
                              ? (_error ? AppTheme.red : AppTheme.gold)
                              : AppTheme.textSecondary,
                          width: 2,
                        ),
                        boxShadow: filled
                            ? [
                                BoxShadow(
                                    color: (_error
                                            ? AppTheme.red
                                            : AppTheme.gold)
                                        .withOpacity(0.4),
                                    blurRadius: 8)
                              ]
                            : null,
                      ),
                    );
                  }),
                ),
              ),
            ),

            if (_error) ...[
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppTheme.red.withOpacity(0.3)),
                ),
                child: Text(_errorMsg,
                    style: const TextStyle(
                        color: AppTheme.red, fontSize: 13)),
              ),
            ],

            const Spacer(),

            // Keypad
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  for (var row in [
                    ['1', '2', '3'],
                    ['4', '5', '6'],
                    ['7', '8', '9'],
                    ['', '0', 'del'],
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: row.map(_buildKey).toList(),
                      ),
                    ),
                ],
              ),
            ),

            if (!widget.isSetup && !widget.isChange) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: _showForgotPin,
                child: const Text('نسيت PIN؟',
                    style: TextStyle(
                        color: AppTheme.gold,
                        fontFamily: 'Cairo',
                        fontSize: 14)),
              ),
            ],
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  Widget _buildKey(String k) {
    if (k.isEmpty) return const SizedBox(width: 72, height: 72);
    return GestureDetector(
      onTap: () => _press(k),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: k == 'del'
              ? AppTheme.gold.withOpacity(0.1)
              : AppTheme.bgCard2,
          border: Border.all(color: AppTheme.border),
        ),
        child: Center(
          child: k == 'del'
              ? const Icon(Icons.backspace_outlined,
                  color: AppTheme.gold, size: 22)
              : Text(k,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
        ),
      ),
    );
  }

  void _showForgotPin(BuildContext? ctx) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('نسيت PIN؟',
            style: TextStyle(
                color: AppTheme.textPrimary, fontFamily: 'Cairo')),
        content: const Text(
          'لإعادة تعيين PIN، يجب حذف بيانات التطبيق من إعدادات الهاتف.',
          style: TextStyle(
              color: AppTheme.textSecondary,
              fontFamily: 'Cairo',
              fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً',
                style: TextStyle(
                    color: AppTheme.gold, fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}
