import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/debt_provider.dart';
import '../utils/app_theme.dart';
import 'pin_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
    _init();
  }

  Future<void> _init() async {
    final auth = context.read<AuthProvider>();
    await auth.init();
    await context.read<DebtProvider>().load();
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    if (auth.hasPin && auth.lockEnabled) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const PinScreen()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.bgGradient),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.gold.withOpacity(0.35),
                        blurRadius: 40,
                        offset: const Offset(0, 12),
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 52,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 28),
                ShaderMask(
                  shaderCallback: (b) =>
                      AppTheme.goldGradient.createShader(b),
                  child: const Text('Debt Tracker Pro',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1)),
                ),
                const SizedBox(height: 8),
                const Text('إدارة ديونك بذكاء واحترافية',
                    style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary)),
                const SizedBox(height: 52),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: AppTheme.gold.withOpacity(0.7),
                    strokeWidth: 2,
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
