import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/service_locator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? 'Login failed')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shop_two, size: 80, color: Colors.blue),
              const SizedBox(height: 32),
              const Text('Mon POS Offline-First', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              // TEMPORARY DIAGNOSTIC — remove once API_BASE_URL is confirmed correct.
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'API: ${sl<Dio>().options.baseUrl}',
                  style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 32),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state.status == AuthStatus.loading) {
                    return const CircularProgressIndicator();
                  }
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(LoginRequested(
                              username: _usernameController.text,
                              password: _passwordController.text,
                            ));
                      },
                      child: const Text('LOGIN'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
