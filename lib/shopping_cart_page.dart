import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tea_go_app/cart_model.dart';
import 'package:tea_go_app/drink_image_widget.dart';
import 'package:tea_go_app/location_model.dart';
import 'package:tea_go_app/payment_success_page.dart';

const Color matchaGreen = Color(0xFFE8F5E9);
const Color darkMatchaGreen = Color(0xFF66BB6A);

class ShoppingCartPage extends StatefulWidget {
  const ShoppingCartPage({super.key});

  @override
  State<ShoppingCartPage> createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  String _selectedPickupTime = 'ASAP (~15 min)';
  String _selectedPayment = 'Touch \'n Go';
  final TextEditingController _promoController = TextEditingController();
  String? _appliedPromo;
  double _discount = 0;

  final List<String> _pickupTimes = [
    'ASAP (~15 min)',
    '30 minutes',
    '45 minutes',
    '1 hour',
  ];

  final List<Map<String, dynamic>> _paymentMethods = [
    {'label': 'Touch \'n Go', 'icon': Icons.account_balance_wallet_outlined},
    {'label': 'Credit Card', 'icon': Icons.credit_card},
    {'label': 'Apple Pay', 'icon': Icons.phone_iphone},
  ];

  final Map<String, double> _promoCodes = {
    'TEA10': 0.10,
    'FIRST20': 0.20,
    'WELCOME': 0.15,
  };

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final code = _promoController.text.trim().toUpperCase();
    if (_promoCodes.containsKey(code)) {
      setState(() {
        _appliedPromo = code;
        _discount = _promoCodes[code]!;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Promo applied! ${(_discount * 100).toInt()}% off'),
          backgroundColor: darkMatchaGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid promo code'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Your cart is empty', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          final subtotal = cart.totalPrice;
          final discountAmount = subtotal * _discount;
          final afterDiscount = subtotal - discountAmount;
          final sst = afterDiscount * 0.06;
          final serviceTax = afterDiscount * 0.10;
          final grandTotal = afterDiscount + sst + serviceTax;
          final roundedTotal = (grandTotal * 20).round() / 20;
          final rounding = roundedTotal - grandTotal;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildOutletCard(context),
                    const SizedBox(height: 12),
                    _buildPickupTimeCard(),
                    const SizedBox(height: 12),
                    _buildItemsCard(cart),
                    const SizedBox(height: 12),
                    _buildOffersCard(),
                    const SizedBox(height: 12),
                    _buildPaymentCard(),
                    const SizedBox(height: 12),
                    _buildPriceSummary(subtotal, discountAmount, sst, serviceTax, rounding, roundedTotal),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              _buildCheckoutBar(context, roundedTotal),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child, IconData? icon}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: darkMatchaGreen),
                const SizedBox(width: 8),
              ],
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildOutletCard(BuildContext context) {
    return Consumer<LocationModel>(
      builder: (context, location, _) {
        return _buildSectionCard(
          title: 'Pickup Outlet',
          icon: Icons.store_outlined,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: matchaGreen, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.location_on, color: darkMatchaGreen, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(location.selectedStall, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
              TextButton(
                onPressed: () => _showLocationDialog(context, location),
                child: const Text('Change', style: TextStyle(color: darkMatchaGreen)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLocationDialog(BuildContext context, LocationModel locationModel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Outlet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...locationModel.stalls.map((stall) => ListTile(
                leading: const Icon(Icons.store_outlined, color: darkMatchaGreen),
                title: Text(stall),
                trailing: locationModel.selectedStall == stall
                    ? const Icon(Icons.check_circle, color: darkMatchaGreen)
                    : null,
                onTap: () {
                  locationModel.selectStall(stall);
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPickupTimeCard() {
    return _buildSectionCard(
      title: 'Estimated Pickup Time',
      icon: Icons.access_time_outlined,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _pickupTimes.map((time) {
          final selected = _selectedPickupTime == time;
          return GestureDetector(
            onTap: () => setState(() => _selectedPickupTime = time),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? darkMatchaGreen : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selected ? darkMatchaGreen : Colors.grey.shade300),
              ),
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildItemsCard(CartModel cart) {
    return _buildSectionCard(
      title: 'Order Items',
      icon: Icons.receipt_long_outlined,
      child: Column(
        children: cart.items.map((item) => _buildCartItem(cart, item)).toList(),
      ),
    );
  }

  Widget _buildCartItem(CartModel cart, CartItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Item icon
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: DrinkImageWidget(
              imageUrl: item.imageUrl,
              height: 52,
              width: 52,
            ),
          ),
          const SizedBox(width: 12),
          // Name & customization
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  '${item.sugarLevel} · ${item.iceLevel}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                if (item.note.isNotEmpty)
                  Text(
                    '📝 ${item.note}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          // Price on top, qty controls on bottom
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'RM ${(item.price * item.quantity).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => cart.decreaseQuantity(item),
                    child: Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.remove, size: 14, color: Colors.black54),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('${item.quantity}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                  GestureDetector(
                    onTap: () => cart.increaseQuantity(item),
                    child: Container(
                      width: 26, height: 26,
                      decoration: const BoxDecoration(color: darkMatchaGreen, shape: BoxShape.circle),
                      child: const Icon(Icons.add, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOffersCard() {
    return _buildSectionCard(
      title: 'Offers & Promo',
      icon: Icons.local_offer_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promoController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Enter promo code',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: darkMatchaGreen),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _applyPromo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkMatchaGreen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('Apply', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          if (_appliedPromo != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: matchaGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: darkMatchaGreen, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '$_appliedPromo applied — ${(_discount * 100).toInt()}% off',
                    style: const TextStyle(fontSize: 13, color: darkMatchaGreen, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() { _appliedPromo = null; _discount = 0; _promoController.clear(); }),
                    child: const Icon(Icons.close, size: 16, color: darkMatchaGreen),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text('Available codes: TEA10 · FIRST20 · WELCOME', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    return _buildSectionCard(
      title: 'Payment Method',
      icon: Icons.payment_outlined,
      child: Column(
        children: _paymentMethods.map((method) {
          final selected = _selectedPayment == method['label'];
          return GestureDetector(
            onTap: () => setState(() => _selectedPayment = method['label']),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? matchaGreen : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? darkMatchaGreen : Colors.grey.shade200,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(method['icon'] as IconData, color: selected ? darkMatchaGreen : Colors.grey.shade500, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    method['label'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: selected ? darkMatchaGreen : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  if (selected) const Icon(Icons.check_circle, color: darkMatchaGreen, size: 18),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceSummary(double subtotal, double discountAmount, double sst, double serviceTax, double rounding, double roundedTotal) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _summaryRow('Subtotal', subtotal),
          if (_discount > 0) ...[
            const SizedBox(height: 8),
            _summaryRow('Discount (${(_discount * 100).toInt()}%)', -discountAmount, valueColor: Colors.green),
          ],
          const SizedBox(height: 8),
          _summaryRow('SST (6%)', sst),
          const SizedBox(height: 8),
          _summaryRow('Service Tax (10%)', serviceTax),
          const SizedBox(height: 8),
          _summaryRow('Rounding', rounding),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                'RM ${roundedTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkMatchaGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double amount, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        Text(
          '${amount < 0 ? '-' : ''}RM ${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: valueColor ?? Colors.black87),
        ),
      ],
    );
  }

  Widget _buildCheckoutBar(BuildContext context, double payable) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkMatchaGreen,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentSuccessPage(totalAmount: payable)));
          },
          child: Text(
            'Proceed to Pay  ·  RM ${payable.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
