import 'package:flutter/material.dart';
import '../../../../core/theme/app_visuals.dart';

class AiArtworkCard extends StatelessWidget {
  final String? imageUrl;
  final bool isGenerating;

  const AiArtworkCard({
    super.key,
    this.imageUrl,
    required this.isGenerating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppShapes.cardBorder,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 1. The Actual Image
          if (imageUrl != null)
            Positioned.fill(
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.broken_image,
                      color: AppColors.textSecondary, size: 40),
                ),
              ),
            ),

          // 2. Overlay: AI is currently generating
          if (isGenerating)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      "AI is painting your day...",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

          // 3. Placeholder: No data yet
          if (imageUrl == null && !isGenerating)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.primary, size: 48),
                  SizedBox(height: 12),
                  Text(
                    "Categorize apps to see your daily art",
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}