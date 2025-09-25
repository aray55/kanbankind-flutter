import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../models/card_model.dart';

class CardCoverWidget extends StatelessWidget {
  final CardModel card;
  final double height;
  final BorderRadius? borderRadius;
  final bool showFullCover;

  const CardCoverWidget({
    Key? key,
    required this.card,
    this.height = 120,
    this.borderRadius,
    this.showFullCover = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!hasCover) return const SizedBox.shrink();

    return Container(
      height: showFullCover ? height : (height * 0.4),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildCoverContent(),
            // Optional overlay for better contrast
            if (hasImageCover)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.05),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverContent() {
    if (hasImageCover) return _buildImageCover();
    if (hasColorCover) return _buildColorCover();
    return const SizedBox.shrink();
  }

  Widget _buildImageCover() {
    return FadeInImage(
      placeholder: MemoryImage(Uint8List.fromList(kTransparentImage)),
      image: FileImage(File(card.coverImage!)),
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 300),
      imageErrorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey, size: 36),
          ),
        );
      },
    );
  }

  Widget _buildColorCover() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _parseColor(card.coverColor!).withOpacity(0.9),
            _parseColor(card.coverColor!).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      String hexColor = colorString.replaceAll('#', '');
      if (hexColor.length == 6) hexColor = 'FF$hexColor';
      return Color(int.parse(hexColor, radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  // Helpers
  bool get hasCover => hasImageCover || hasColorCover;
  bool get hasImageCover =>
      card.coverImage != null && card.coverImage!.isNotEmpty;
  bool get hasColorCover =>
      card.coverColor != null && card.coverColor!.isNotEmpty;
}

// Transparent image for FadeInImage placeholder
final kTransparentImage = <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
];
