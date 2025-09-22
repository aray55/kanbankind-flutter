import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DragController extends GetxController {
  final ScrollController scrollController;
  Timer? _autoScrollTimer;
  bool _isDragging = false;

  DragController({required this.scrollController});

  void handleDragStart() {
    _isDragging = true;
  }

  void handleDragEnd() {
    _isDragging = false;
    _stopAutoScroll();
  }

  void handlePointerMove(PointerMoveEvent event, BuildContext context) {
    if (!_isDragging) return;

    const double hotZoneWidth = 100.0;
    const double scrollSpeed = 10.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final position = event.position.dx;

    if (position < hotZoneWidth) {
      // scroll left
      if (scrollController.position.pixels >
          scrollController.position.minScrollExtent) {
        _startAutoScroll(-scrollSpeed);
      }
    } else if (position > screenWidth - hotZoneWidth) {
      // scroll right
      if (scrollController.position.pixels <
          scrollController.position.maxScrollExtent) {
        _startAutoScroll(scrollSpeed);
      }
    } else {
      _stopAutoScroll();
    }
  }

  void _startAutoScroll(double velocity) {
    if (_autoScrollTimer == null || !_autoScrollTimer!.isActive) {
      _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
        final newOffset = scrollController.offset + velocity;
        if (newOffset >= scrollController.position.minScrollExtent &&
            newOffset <= scrollController.position.maxScrollExtent) {
          scrollController.jumpTo(newOffset);
        } else {
          _stopAutoScroll();
        }
      });
    }
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  @override
  void onClose() {
    _stopAutoScroll();
    super.onClose();
  }
}
