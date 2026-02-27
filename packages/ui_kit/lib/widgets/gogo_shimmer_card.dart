import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:core/core.dart';

class GogoShimmerCard extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const GogoShimmerCard({
    super.key,
    this.width = double.infinity,
    this.height = 200,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.bgSurface,
      highlightColor: AppColors.divider,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
