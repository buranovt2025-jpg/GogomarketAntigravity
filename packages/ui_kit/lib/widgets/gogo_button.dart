import 'package:flutter/material.dart';
import 'package:core/core.dart';

enum GogoButtonVariant { primary, secondary, ghost }
enum GogoButtonSize { large, medium, small }

class GogoButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final GogoButtonVariant variant;
  final GogoButtonSize size;
  final Widget? icon;
  final bool isLoading;
  final bool fullWidth;

  const GogoButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = GogoButtonVariant.primary,
    this.size = GogoButtonSize.large,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _height,
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    switch (variant) {
      case GogoButtonVariant.primary:
        return _PrimaryButton(
          label: label,
          onPressed: isLoading ? null : onPressed,
          icon: icon,
          isLoading: isLoading,
          height: _height,
          textStyle: _textStyle,
          horizontalPadding: _hPadding,
        );
      case GogoButtonVariant.secondary:
        return _SecondaryButton(
          label: label,
          onPressed: isLoading ? null : onPressed,
          icon: icon,
          isLoading: isLoading,
          height: _height,
          textStyle: _textStyle,
          horizontalPadding: _hPadding,
        );
      case GogoButtonVariant.ghost:
        return _GhostButton(
          label: label,
          onPressed: isLoading ? null : onPressed,
          icon: icon,
          isLoading: isLoading,
          height: _height,
          textStyle: _textStyle,
          horizontalPadding: _hPadding,
        );
    }
  }

  double get _height => switch (size) {
        GogoButtonSize.large => 52,
        GogoButtonSize.medium => 44,
        GogoButtonSize.small => 36,
      };

  TextStyle get _textStyle => switch (size) {
        GogoButtonSize.large => AppTextStyles.button,
        GogoButtonSize.medium =>
          AppTextStyles.button.copyWith(fontSize: 14),
        GogoButtonSize.small =>
          AppTextStyles.button.copyWith(fontSize: 12),
      };

  double get _hPadding => switch (size) {
        GogoButtonSize.large => 24,
        GogoButtonSize.medium => 20,
        GogoButtonSize.small => 16,
      };
}

// === Primary Button — Orange Gradient ===
class _PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final double height;
  final TextStyle textStyle;
  final double horizontalPadding;

  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    required this.icon,
    required this.isLoading,
    required this.height,
    required this.textStyle,
    required this.horizontalPadding,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) {
        _controller.forward();
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: widget.height,
          padding:
              EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          widget.icon!,
          const SizedBox(width: 8),
        ],
        Text(widget.label, style: widget.textStyle),
      ],
    );
  }
}

// === Secondary Button — Outlined ===
class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final double height;
  final TextStyle textStyle;
  final double horizontalPadding;

  const _SecondaryButton({
    required this.label,
    required this.onPressed,
    required this.icon,
    required this.isLoading,
    required this.height,
    required this.textStyle,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        foregroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 8)],
                Text(label, style: textStyle.copyWith(color: AppColors.primary)),
              ],
            ),
    );
  }
}

// === Ghost Button — No border ===
class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final double height;
  final TextStyle textStyle;
  final double horizontalPadding;

  const _GhostButton({
    required this.label,
    required this.onPressed,
    required this.icon,
    required this.isLoading,
    required this.height,
    required this.textStyle,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 8)],
          Text(label, style: textStyle.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}
