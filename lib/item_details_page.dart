import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tea_go_app/cart_model.dart';

const Color darkMatchaGreen = Color(0xFF66BB6A);

class ItemDetailsPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const ItemDetailsPage({super.key, required this.item});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  String _sugarLevel = '正常';
  String _iceLevel = '正常冰';
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOptionSelector('糖度', ['正常', '少糖', '半塘', '微糖', '无糖'], _sugarLevel, (value) {
              setState(() {
                _sugarLevel = value;
              });
            }),
            const SizedBox(height: 20),
            _buildOptionSelector('冰块', ['正常冰', '少冰', '去冰', '热'], _iceLevel, (value) {
              setState(() {
                _iceLevel = value;
              });
            }),
            const SizedBox(height: 20),
            _buildQuantitySelector(),
            const Spacer(),
            _buildAddToCartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionSelector(String title, List<String> options, String selectedValue, ValueChanged<String> onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10.0,
          children: options.map((option) {
            return ChoiceChip(
              label: Text(option),
              selected: selectedValue == option,
              onSelected: (selected) {
                if (selected) {
                  onSelected(option);
                }
              },
              selectedColor: darkMatchaGreen,
              labelStyle: TextStyle(color: selectedValue == option ? Colors.white : Colors.black),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('数量', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () {
                if (_quantity > 1) {
                  setState(() {
                    _quantity--;
                  });
                }
              },
            ),
            Text('$_quantity', style: const TextStyle(fontSize: 18)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                setState(() {
                  _quantity++;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddToCartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkMatchaGreen,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onPressed: () {
          final cart = Provider.of<CartModel>(context, listen: false);
          final newItem = CartItem(
            name: widget.item['name'],
            price: widget.item['price'],
            sugarLevel: _sugarLevel,
            iceLevel: _iceLevel,
            quantity: _quantity,
          );
          cart.add(newItem);
          Navigator.pop(context);
        },
        child: const Text(
          '加入购物车',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
