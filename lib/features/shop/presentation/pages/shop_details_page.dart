import '../../../../core/widgets/input_label.dart';
import '../../../../core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/shop_bloc.dart';
import '../../domain/entities/shop.dart';
import '../../../../core/theme/app_theme.dart';

class ShopDetailsPage extends StatefulWidget {
  const ShopDetailsPage({super.key});

  @override
  State<ShopDetailsPage> createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _address1;
  late String _address2;
  late String _phone;
  late String _upi;
  late String _footer;

  @override
  void initState() {
    super.initState();
    final shop = context.read<ShopBloc>().state.shop;
    _name = shop.name;
    _address1 = shop.addressLine1;
    _address2 = shop.addressLine2;
    _phone = shop.phoneNumber;
    _upi = shop.upiId;
    _footer = shop.footerText;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final currentShop = context.read<ShopBloc>().state.shop;
      final updatedShop = currentShop.copyWith(
        name: _name,
        addressLine1: _address1,
        addressLine2: _address2,
        phoneNumber: _phone,
        upiId: _upi,
        footerText: _footer,
      );

      context.read<ShopBloc>().add(UpdateShopEvent(updatedShop));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil de la Boutique'),
        centerTitle: true,
      ),
      body: BlocConsumer<ShopBloc, ShopState>(
        listener: (context, state) {
          if (state.status == ShopStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Boutique mise à jour !'), backgroundColor: Colors.green),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const InputLabel(text: 'Nom de la Boutique'),
                  TextFormField(
                    initialValue: _name,
                    decoration: const InputDecoration(hintText: 'Mon Magasin'),
                    onSaved: (v) => _name = v ?? '',
                  ),
                  const SizedBox(height: 24),
                  const InputLabel(text: 'Adresse (Ligne 1)'),
                  TextFormField(
                    initialValue: _address1,
                    onSaved: (v) => _address1 = v ?? '',
                  ),
                  const SizedBox(height: 24),
                  const InputLabel(text: 'Adresse (Ligne 2)'),
                  TextFormField(
                    initialValue: _address2,
                    onSaved: (v) => _address2 = v ?? '',
                  ),
                  const SizedBox(height: 24),
                  const InputLabel(text: 'Téléphone'),
                  TextFormField(
                    initialValue: _phone,
                    keyboardType: TextInputType.phone,
                    onSaved: (v) => _phone = v ?? '',
                  ),
                  const SizedBox(height: 24),
                  const InputLabel(text: 'Identifiant Taxe / UPI'),
                  TextFormField(
                    initialValue: _upi,
                    onSaved: (v) => _upi = v ?? '',
                  ),
                  const SizedBox(height: 24),
                  const InputLabel(text: 'Pied de page ticket'),
                  TextFormField(
                    initialValue: _footer,
                    decoration: const InputDecoration(hintText: 'Merci de votre visite !'),
                    onSaved: (v) => _footer = v ?? '',
                  ),
                  const SizedBox(height: 40),
                  PrimaryButton(
                    onPressed: _submit,
                    icon: Icons.save,
                    label: 'Enregistrer le Profil',
                    isLoading: state.status == ShopStatus.loading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
