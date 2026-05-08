import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (!success && authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(20),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D3B66), Color(0xFF1A5C8A), Color(0xFF2B7CB4)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo and Title
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.shield,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Uganda Prisons Service',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Visitor Management System',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 48),

                          // Login Card
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Staff Login',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Enter your credentials to continue',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Email Field
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    labelText: 'Email Address',
                                    hintText: 'staff@prisons.go.ug',
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.email_outlined,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email is required';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Valid email required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Password Field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: const TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    hintText: 'Enter your password',
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.lock_outlined,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.grey.shade500,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is required';
                                    }
                                    if (value.length < 6) {
                                      return 'Password too short';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Remember Me & Forgot Password
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: Checkbox(
                                            value: _rememberMe,
                                            onChanged: (value) {
                                              setState(
                                                () => _rememberMe = value!,
                                              );
                                            },
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            activeColor:
                                                theme.colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Remember me',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Forgot password functionality
                                      },
                                      child: Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),

                                // Login Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: authProvider.isLoading
                                        ? null
                                        : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      shadowColor: theme.colorScheme.primary
                                          .withOpacity(0.3),
                                    ),
                                    child: authProvider.isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Sign In',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(Icons.arrow_forward),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Authorized Personnel Only',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
