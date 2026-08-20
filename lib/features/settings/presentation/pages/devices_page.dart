import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appareils Autorisés'),
        centerTitle: true,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final bool isAuthorized = state.user?.isDeviceAuthorized ?? false;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.phone_android, color: Colors.blue),
                  title: const Text('Cet appareil'),
                  subtitle: Text(isAuthorized ? 'Autorisé' : 'En attente d\'approbation'),
                  trailing: Icon(
                    isAuthorized ? Icons.check_circle : Icons.hourglass_empty,
                    color: isAuthorized ? Colors.green : Colors.orange,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Note: Contactez l\'administrateur pour autoriser un nouvel appareil.',
                style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }
}
