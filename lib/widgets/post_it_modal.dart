import 'package:flutter/material.dart';
import '../models/farmacia.dart';
import '../theme/app_theme.dart';

/// Modal de Post-It de farmacia (solo lectura).
class PostItModal extends StatelessWidget {
  final PostIt postIt;

  const PostItModal({super.key, required this.postIt});

  static Future<void> show(BuildContext context, PostIt postIt) {
    return showDialog(
      context: context,
      builder: (_) => PostItModal(postIt: postIt),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fields = postIt.filledFields;

    return Dialog(
      backgroundColor: AppColors.postIt,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '📝 Datos Particulares',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.postItText,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: AppColors.textMuted, size: 24),
                  ),
                ],
              ),
              const Divider(color: AppColors.postItBorder, height: 24),
              // Contenido
              Flexible(
                child: fields.isEmpty
                    ? const Center(
                        child: Text(
                          'Sin notas disponibles',
                          style: TextStyle(fontSize: 14, color: AppColors.textDisabled),
                        ),
                      )
                    : ListView(
                        shrinkWrap: true,
                        children: fields.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF975a16),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  entry.value,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
