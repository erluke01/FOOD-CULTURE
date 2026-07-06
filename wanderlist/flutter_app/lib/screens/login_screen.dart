import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              // Logo area
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.terra.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.travel_explore, size: 36, color: AppTheme.terra),
              ),
              const SizedBox(height: 20),
              const Text('Bentornati', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Accedi per aggiungere posti e voti',
                style: TextStyle(color: AppTheme.inkColor.withOpacity(0.5), fontSize: 14)),
              const SizedBox(height: 32),

              // Form
              TextField(
                controller: _username,
                decoration: const InputDecoration(
                  labelText: 'Nome utente',
                  hintText: 'luchino o alix',
                  prefixIcon: Icon(Icons.person_outline, size: 20),
                ),
                autocorrect: false,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _login(),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    Icon(Icons.error_outline, size: 16, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Text(_error!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
                  ]),
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: auth.isLoading ? null : _login,
                  icon: auth.isLoading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.login, size: 18),
                  label: Text(auth.isLoading ? 'Accesso…' : 'Accedi'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Continua come ospite →'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() => _error = null);
    try {
      await ref.read(authProvider.notifier).login(
        _username.text.trim().toLowerCase(),
        _password.text,
      );
      if (mounted && ref.read(authProvider).hasValue && ref.read(authProvider).value != null) {
        context.pop();
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
