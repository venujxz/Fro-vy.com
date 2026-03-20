// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  final String planName;
  final String price;
  final String period;

  const CheckoutScreen({
    super.key,
    required this.planName,
    required this.price,
    required this.period,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Brand Colors
  static const Color frovyGreen  = Color(0xFF6AA15E);
  static const Color frovyLightBg = Color(0xFFF8F9FA);

  int _selectedPaymentMethod = 0; // 0 = Card, 1 = PayPal, 2 = Apple Pay
  bool _isProcessing = false;

  // ─────────────────────────────────────────
  // Payment Logic
  // ─────────────────────────────────────────

  Future<void> _handlePayment() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    _showSnackBar('Processing Payment... (Mock)');

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isProcessing = false);

    Navigator.pop(context, widget.planName);

    _showSnackBar('Welcome to Premium!');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ─────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: frovyGreen,
      appBar: AppBar(
        backgroundColor: frovyGreen,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _isProcessing ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildBody(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Widgets
  // ─────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      width: double.infinity,
      child: const Column(
        children: [
          Text(
            'Complete Purchase',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Review your plan and select a payment method',
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: frovyLightBg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderSummary(),
              const SizedBox(height: 24),
              _buildPaymentSection(),
              const SizedBox(height: 40),
              _buildPayButton(),
              const SizedBox(height: 20),
              _buildFooterNote(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fro-vy ${widget.planName}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                widget.price,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Billed ${widget.period}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Today',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.price,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: frovyGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(0, 'Credit / Debit Card', Icons.credit_card),
        _buildPaymentOption(1, 'PayPal', Icons.payment),
        _buildPaymentOption(2, 'Apple Pay', Icons.phone_iphone),
      ],
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _handlePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: frovyGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: frovyGreen.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isProcessing
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Pay ${widget.price}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildFooterNote() {
    return Center(
      child: Text(
        'Cancel Anytime. Secure Payment.',
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
      ),
    );
  }

  Widget _buildPaymentOption(int index, String title, IconData icon) {
    final bool isSelected = _selectedPaymentMethod == index;

    return GestureDetector(
      onTap: _isProcessing ? null : () => setState(() => _selectedPaymentMethod = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? frovyGreen : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? frovyGreen : Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: frovyGreen, size: 20),
          ],
        ),
      ),
    );
  }
}