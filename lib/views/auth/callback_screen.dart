import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/dormmate_constants.dart';
import '../../core/localization/language_service.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/neumorphic.dart';

/// Screen displayed upon OIDC redirect callback to process code and exchange tokens.
class CallbackScreen extends StatefulWidget {
  const CallbackScreen({super.key});

  @override
  State<CallbackScreen> createState() => _CallbackScreenState();
}

class _CallbackScreenState extends State<CallbackScreen> {
  String? _errorMessage;
  bool _isProcessing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processCallback();
    });
  }

  Future<void> _processCallback() async {
    final hasCode = Uri.base.queryParameters.containsKey('code') ||
        Uri.base.fragment.contains('code=');
    if (!hasCode) {
      if (mounted) context.go('/login');
      return;
    }

    try {
      final authVm = context.read<AuthViewModel>();
      final success = await authVm.handleOidcCallback();
      if (success && mounted) {
        context.go('/home');
      } else if (mounted) {
        setState(() {
          _errorMessage = authVm.errorMessage ?? 'OIDC sign-in could not be completed.';
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error processing callback: $e';
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isThai = context.watch<LanguageService?>()?.isThai ?? false;

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgDark : NeuColors.bgLight,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: NeuContainer(
              isDark: isDark,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              borderRadius: 24,
              shadowIntensity: 1.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isProcessing) ...[
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: NeuColors.primaryGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isThai ? 'กำลังยืนยันตัวตนผ่าน OIDC...' : 'Completing OIDC Sign-In...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: DormMateColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isThai
                          ? 'กำลังแลกเปลี่ยน Token กับ OIDC Provider'
                          : 'Exchanging authorization code with provider',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: DormMateColors.textSecondary,
                      ),
                    ),
                  ] else ...[
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.redAccent,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isThai ? 'เข้าสู่ระบบไม่สำเร็จ' : 'Sign-In Failed',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: DormMateColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _errorMessage ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: DormMateColors.statusErrorText,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: NeuButton(
                        isDark: isDark,
                        gradientColors: NeuColors.primaryGradient,
                        borderRadius: 14,
                        onTap: () => context.go('/login'),
                        child: Text(
                          isThai ? 'กลับไปหน้าเข้าสู่ระบบ' : 'Back to Sign In',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
