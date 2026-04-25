import 'package:flutter/material.dart';

class FeedHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  final Size preferredSize;

  FeedHeader({
    super.key,
    required this.title,
    this.leading,
    this.actions,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFA03A57),
              ),
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
