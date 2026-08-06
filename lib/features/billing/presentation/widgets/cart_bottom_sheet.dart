import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/billing_bloc.dart';

class CartBottomSheet extends StatelessWidget {
  const CartBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BillingBloc, BillingState>(
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Shopping Cart",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (state.cartItems.isEmpty)
                  const SizedBox(
                    height: 200,
                    child: Center(child: Text("Cart is empty")),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.45,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: state.cartItems.length,
                      separatorBuilder: (context, index) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final item = state.cartItems[index];
                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    "${item.product.price.toStringAsFixed(3)} TND",
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_rounded, size: 20),
                                    onPressed: () {
                                      if (item.quantity > 1) {
                                        context.read<BillingBloc>().add(UpdateQuantityEvent(
                                            item.product.id, item.quantity - 1));
                                      } else {
                                        context.read<BillingBloc>().add(
                                            RemoveProductFromCartEvent(item.product.id));
                                      }
                                    },
                                  ),
                                  Text(
                                    "${item.quantity}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_rounded, size: 20),
                                    onPressed: () {
                                      context.read<BillingBloc>().add(UpdateQuantityEvent(
                                          item.product.id, item.quantity + 1));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${state.totalAmount.toStringAsFixed(3)} TND",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          context.read<BillingBloc>().add(ClearCartEvent());
                          Navigator.pop(context);
                        },
                        child: const Text("Clear"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: state.cartItems.isEmpty
                            ? null
                            : () {
                                Navigator.pop(context);
                                context.push('/checkout');
                              },
                        child: const Text(
                          "CHECKOUT",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
