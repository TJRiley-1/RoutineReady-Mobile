import 'package:flutter/material.dart';

class NotificationToast extends StatelessWidget {
  final String message;
  final String type;
  final VoidCallback? onDismiss;

  const NotificationToast({
    super.key,
    required this.message,
    this.type = 'info',
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case 'success':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle;
      case 'error':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade800;
        icon = Icons.error;
      case 'warning':
        bgColor = Colors.amber.shade50;
        textColor = Colors.amber.shade800;
        icon = Icons.warning;
      default:
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade800;
        icon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: Icon(Icons.close, size: 18, color: textColor),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
