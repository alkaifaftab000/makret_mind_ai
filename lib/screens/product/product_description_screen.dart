import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/models/product_model.dart';
import 'package:market_mind/screens/product/poster_config_screen.dart';

/// Legacy screen — redirects to PosterConfigScreen.
/// Will be rewritten for video editing flow in a future update.
class ProductDescriptionScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDescriptionScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Redirect to the new poster/product detail screen
    return PosterConfigScreen(product: product);
  }
}
