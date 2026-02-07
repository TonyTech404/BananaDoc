import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData icon;
  final Color? color;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.icon,
    this.color,
    this.type = ButtonType.filled,
    this.size = ButtonSize.medium,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.colorScheme.primary;
    
    // Size configurations
    EdgeInsets padding;
    double iconSize;
    double fontSize;

    switch (size) {
      case ButtonSize.small:
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
        iconSize = 18.0;
        fontSize = 14.0;
        break;
      case ButtonSize.medium:
        padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
        iconSize = 20.0;
        fontSize = 16.0;
        break;
      case ButtonSize.large:
        padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
        iconSize = 24.0;
        fontSize = 18.0;
        break;
    }

    switch (type) {
      case ButtonType.filled:
        return _buildFilledButton(
            context, buttonColor, padding, iconSize, fontSize);
      case ButtonType.outlined:
        return _buildOutlinedButton(
            context, buttonColor, padding, iconSize, fontSize);
      case ButtonType.text:
        return _buildTextButton(
            context, buttonColor, padding, iconSize, fontSize);
    }
  }

  Widget _buildFilledButton(BuildContext context, Color buttonColor,
      EdgeInsets padding, double iconSize, double fontSize) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: isLoading ? 0 : 2,
        shadowColor: buttonColor.withValues(alpha: 0.3),
      ),
      child: _buildButtonContent(iconSize, fontSize, Colors.white),
    );
  }

  Widget _buildOutlinedButton(BuildContext context, Color buttonColor,
      EdgeInsets padding, double iconSize, double fontSize) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: buttonColor,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        side: BorderSide(color: buttonColor, width: 1.5),
      ),
      child: _buildButtonContent(iconSize, fontSize, buttonColor),
    );
  }

  Widget _buildTextButton(BuildContext context, Color buttonColor,
      EdgeInsets padding, double iconSize, double fontSize) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: buttonColor,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: _buildButtonContent(iconSize, fontSize, buttonColor),
    );
  }

  Widget _buildButtonContent(double iconSize, double fontSize, Color color) {
    if (isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

enum ButtonType { filled, outlined, text }
enum ButtonSize { small, medium, large } 