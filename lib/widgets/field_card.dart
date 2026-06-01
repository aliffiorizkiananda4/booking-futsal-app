import 'package:flutter/material.dart';
import 'package:inventory_apps/models/field_model.dart';

class FieldCard extends StatelessWidget {
  final FieldModel field;
  final VoidCallback? onTap;

  const FieldCard({super.key, required this.field, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: field.image != null
                  ? Image.network(
                      field.image!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: double.infinity,
                        height: 180,
                        color: const Color(0xFFF1F5F9),
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: Color(0xFF94A3B8),
                          size: 48,
                        ),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      height: 180,
                      color: const Color(0xFFDCFCE7),
                      child: const Icon(
                        Icons.sports_soccer_outlined,
                        color: Color(0xFF22C55E),
                        size: 64,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          field.type,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF22C55E),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Rp ${field.price}/jam',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF22C55E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
