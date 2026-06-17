import 'package:flutter/material.dart';

class CarouselItem {
  final int? id;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback? onTap;

  CarouselItem({
    required this.title,
    required this.subtitle,
    required this.gradient,
    this.onTap,
    this.id,
  });
}
