import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:tea_go_app/cart_model.dart';
import 'package:tea_go_app/drink_image_widget.dart';

const Color matchaGreen = Color(0xFFE8F5E9);
const Color darkMatchaGreen = Color(0xFF66BB6A);

class ItemDetailsPage extends StatefulWidget {
  final Map<String, dynamic> item;
  const ItemDetailsPage({super.key, required this.item});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  late String _sugarLevel;
  late String _iceLevel;
  int _quantity = 1;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final sugarLevels = List<String>.from(widget.item['sugarLevels'] as List? ?? ['Normal']);
    final iceLevels = List<String>.from(widget.item['iceLevels'] as List? ?? ['Normal Ice']);
    _sugarLevel = sugarLevels[sugarLevels.length ~/ 2];
    _iceLevel = iceLevels.contains('Normal Ice') ? 'Normal Ice' : iceLevels.first;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleRow(),
                  const SizedBox(height: 8),
                  _buildDescription(),
                  const SizedBox(height: 10),
                  _buildTags(),
                  const SizedBox(height: 20),
                  _buildSectionLabel('Sugar Level'),
                  const SizedBox(height: 10),
                  _buildChipSelector(
                    List<String>.from(widget.item['sugarLevels'] as List? ?? ['Normal']),
                    _sugarLevel,
                    (v) => setState(() => _sugarLevel = v),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionLabel('Ice Level'),
                  const SizedBox(height: 10),
                  _buildChipSelector(
                    List<String>.from(widget.item['iceLevels'] as List? ?? ['Normal Ice']),
                    _iceLevel,
                    (v) => setState(() => _iceLevel = v),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionLabel('Quantity'),
                  const SizedBox(height: 10),
                  _buildQuantitySelector(),
                  const SizedBox(height: 20),
                  _buildSectionLabel('Special Note'),
                  const SizedBox(height: 10),
                  _buildNoteField(),
                  const SizedBox(height: 32),
                  _buildAddToCartButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: Colors.white,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            ShadToaster.of(context).show(
              const ShadToast(description: Text('Share link copied!')),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.share_outlined, color: Colors.black87),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: DrinkImageWidget(
          imageUrl: widget.item['imageUrl'] as String? ?? '',
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.item['name'],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'RM ${(widget.item['price'] as double).toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: darkMatchaGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      'A carefully crafted drink made with premium ingredients. Freshly prepared for every order.',
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade600,
        height: 1.5,
      ),
    );
  }

  Widget _buildTags() {
    final tags = <Widget>[];
    if (widget.item['bestSeller'] == true) {
      tags.add(_tag('Best Seller', Colors.orange.shade100, Colors.orange.shade700));
    }
    if (widget.item['featured'] == true) {
      tags.add(_tag('Featured', Colors.blue.shade50, Colors.blue.shade700));
    }
    final calorie = widget.item['calorieLevel'] as String?;
    if (calorie != null) {
      final Color bg, fg;
      switch (calorie) {
        case 'Low':
          bg = const Color(0xFFE8F5E9); fg = const Color(0xFF66BB6A);
        case 'Medium':
          bg = Colors.orange.shade50; fg = Colors.orange.shade700;
        default:
          bg = Colors.red.shade50; fg = Colors.red.shade700;
      }
      tags.add(_tag('$calorie Cal', bg, fg));
    }
    if (tags.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 8, runSpacing: 6, children: tags);
  }

  Widget _tag(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildChipSelector(List<String> options, String selected, ValueChanged<String> onSelect) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected == option;
        return GestureDetector(
          onTap: () => onSelect(option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? darkMatchaGreen : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? darkMatchaGreen : Colors.grey.shade300,
              ),
            ),
            child: Text(
              option,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (_quantity > 1) setState(() => _quantity--);
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(Icons.remove, size: 18, color: Colors.black87),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '$_quantity',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => _quantity++),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: darkMatchaGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, size: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteField() {
    return ShadInput(
      controller: _noteController,
      maxLines: 3,
      placeholder: const Text('e.g. Less sweet, no pearls, extra toppings...'),
    );
  }

  Widget _buildAddToCartButton() {
    return SizedBox(
      width: double.infinity,
      child: ShadButton(
        onPressed: () {
          final cart = Provider.of<CartModel>(context, listen: false);
          cart.add(CartItem(
            name: widget.item['name'],
            price: widget.item['price'],
            sugarLevel: _sugarLevel,
            iceLevel: _iceLevel,
            quantity: _quantity,
            note: _noteController.text.trim(),
            imageUrl: widget.item['imageUrl'] as String? ?? '',
          ));
          Navigator.pop(context);
        },
        child: const Text('Add to Cart', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
