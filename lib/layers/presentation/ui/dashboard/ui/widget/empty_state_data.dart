import 'package:flutter/material.dart';

import '../../../../../../assets/colors/Colors.dart';
import '../../../../../../core/app/style.dart';
import '../../../../../../core/extension/color.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;

  const EmptyStateWidget({
    Key? key,
    this.message = "You still don't have any data!",
    this.icon = Icons.inbox,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: ColorUtil.getColor(context)!.kGrey),
          const SizedBox(height: 16),
          Text(
            message,
            style:  TextStyle(fontSize: 16, color: ColorUtil.getColor(context)!.kGrey),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text("Try again"),
            ),
          ]
        ],
      ),
    );
  }
}
