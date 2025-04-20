import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../config/theme.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CartService _cartService = CartService();
  final OrderService _orderService = OrderService();
  
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  String? _selectedAddress;
  String? _selectedPaymentMethod = 'card';
  String? _notes;
  bool _isLoading = false;
  List<String> _addresses = [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    // TODO: Charger les adresses depuis le service utilisateur
    setState(() {
      _addresses = [
        '123 Rue Principale, 75001 Paris',
        '456 Avenue des Fleurs, 69000 Lyon',
      ];
      
      if (_addresses.isNotEmpty) {
        _selectedAddress = _addresses[0];
      }
    });
  }

  Future<void> _placeOrder() async {
    if (_selectedAddress == null || _selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Synchroniser le panier avec le backend
      await _cartService.syncCartWithBackend();
      
      // Passer la commande
      final order = await _orderService.createOrder(
        address: _selectedAddress!,
        paymentMethod: _selectedPaymentMethod!,
        notes: _notesController.text,
      );
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderConfirmationScreen(order: order),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la commande: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalisation de la commande'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Adresse de livraison
                  const Text(
                    'Adresse de livraison',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildAddressSelector(),
                  const SizedBox(height: 24),

                  // Méthode de paiement
                  const Text(
                    'Méthode de paiement',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentMethodSelector(),
                  const SizedBox(height: 24),

                  // Notes
                  const Text(
                    'Notes (optionnel)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      hintText: 'Instructions spéciales pour la livraison',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAddressSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_addresses.isEmpty)
              const Text('Aucune adresse enregistrée')
            else
              Column(
                children: _addresses.map((address) {
                  return RadioListTile<String>(
                    title: Text(address),
                    value: address,
                    groupValue: _selectedAddress,
                    onChanged: (value) {
                      setState(() {
                        _selectedAddress = value;
                      });
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Ouvrir le formulaire d'ajout d'adresse
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité à venir')),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une adresse'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Card(
      child: Column(
        children: [
          RadioListTile<String>(
            title: const Text('Carte de crédit'),
            subtitle: const Text('Visa, Mastercard, etc.'),
            value: 'card',
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('PayPal'),
            value: 'paypal',
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Paiement à la livraison'),
            value: 'cod',
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              FutureBuilder<double>(
                future: _cartService.calculateTotal(),
                builder: (context, snapshot) {
                  final total = snapshot.data ?? 0.0;
                  return Text(
                    '$total €',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppTheme.primaryColor,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _placeOrder,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Confirmer la commande',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
} 