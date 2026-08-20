import 'package:flutter/material.dart';

Widget webinarPriceLabel({required String? isPaid, required String? price}) {
  final paid =
      isPaid == '1' ||
      isPaid?.toLowerCase() == 'true' ||
      isPaid?.toLowerCase() == 'paid';

  if (paid) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.workspace_premium_outlined,
          color: Colors.orangeAccent,
          size: 16,
        ),
        const SizedBox(width: 5),
        Text(
          'Paid • ₹${price ?? '0'}',
          style: const TextStyle(
            color: Colors.orangeAccent,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.green.withOpacity(.12),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Text(
      'Free',
      style: TextStyle(
        color: Colors.greenAccent,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
